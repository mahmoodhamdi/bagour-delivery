/**
 * Marketing capture — Bagour Delivery (restaurant + admin dashboards).
 *
 * For now we screenshot the public auth pages plus what we can reach via
 * cookie-seeded auth state. The full dashboard tour requires a follow-up
 * fix for the persist-rehydration race in the layout's auth check (see
 * INTERNAL_AUDIT.md).
 */
import { chromium } from '@playwright/test';
import path from 'node:path';
import fs from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');
const shotsDir = path.join(projectRoot, 'marketing', 'screenshots');
const videosDir = path.join(projectRoot, 'marketing', 'videos');
const REST_BASE = process.env.RESTAURANT_BASE_URL || 'http://localhost:3005';
const ADMIN_BASE = process.env.ADMIN_BASE_URL || 'http://localhost:3006';

await fs.mkdir(shotsDir, { recursive: true });
await fs.mkdir(videosDir, { recursive: true });

const desktop = { width: 1920, height: 1080 };
const tablet  = { width: 1024, height: 768  };
const mobile  = { width: 390,  height: 844  };

async function shot(page, name) {
  const file = path.join(shotsDir, `${name}.png`);
  await page.screenshot({ path: file, fullPage: false });
  console.log(`  + ${path.relative(projectRoot, file)}`);
}

const browser = await chromium.launch({ channel: 'chrome', headless: true });
try {
  console.log('\n=== Restaurant dashboard public pages ===');
  {
    const ctx = await browser.newContext({ viewport: desktop, locale: 'ar-EG' });
    const page = await ctx.newPage();

    for (const [name, url] of [
      ['01-restaurant-desktop-login', '/login'],
      ['02-restaurant-desktop-register', '/register'],
      ['03-restaurant-desktop-forgot', '/forgot-password'],
    ]) {
      await page.goto(`${REST_BASE}${url}`, { waitUntil: 'networkidle' }).catch(() => {});
      await page.waitForTimeout(1500);
      await shot(page, name);
    }
    await ctx.close();
  }

  console.log('\n=== Admin dashboard public pages ===');
  {
    const ctx = await browser.newContext({ viewport: desktop, locale: 'ar-EG' });
    const page = await ctx.newPage();
    await page.goto(`${ADMIN_BASE}/login`, { waitUntil: 'networkidle' }).catch(() => {});
    await page.waitForTimeout(1500);
    await shot(page, '04-admin-desktop-login');
    await ctx.close();
  }

  console.log('\n=== Mobile views ===');
  {
    const ctx = await browser.newContext({
      viewport: mobile, locale: 'ar-EG', isMobile: true, hasTouch: true,
      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    });
    const page = await ctx.newPage();
    await page.goto(`${REST_BASE}/login`, { waitUntil: 'networkidle' }).catch(() => {});
    await page.waitForTimeout(1500);
    await shot(page, '05-restaurant-mobile-login');
    await page.goto(`${REST_BASE}/register`, { waitUntil: 'networkidle' }).catch(() => {});
    await page.waitForTimeout(1500);
    await shot(page, '06-restaurant-mobile-register');
    await page.goto(`${ADMIN_BASE}/login`, { waitUntil: 'networkidle' }).catch(() => {});
    await page.waitForTimeout(1500);
    await shot(page, '07-admin-mobile-login');
    await ctx.close();
  }

  console.log('\n=== Tablet views ===');
  {
    const ctx = await browser.newContext({ viewport: tablet, locale: 'ar-EG' });
    const page = await ctx.newPage();
    await page.goto(`${REST_BASE}/login`, { waitUntil: 'networkidle' }).catch(() => {});
    await page.waitForTimeout(1500);
    await shot(page, '08-restaurant-tablet-login');
    await ctx.close();
  }

  console.log('\n=== walkthrough video (login pages tour) ===');
  {
    const ctx = await browser.newContext({
      viewport: desktop, locale: 'ar-EG',
      recordVideo: { dir: videosDir, size: desktop },
    });
    const page = await ctx.newPage();
    for (const url of [
      `${REST_BASE}/login`,
      `${REST_BASE}/register`,
      `${REST_BASE}/forgot-password`,
      `${ADMIN_BASE}/login`,
    ]) {
      await page.goto(url, { waitUntil: 'networkidle' }).catch(() => {});
      await page.waitForTimeout(4500);
    }
    await ctx.close();
    console.log('  + walkthrough webm');
  }
} finally {
  await browser.close();
}
console.log('\nDone.');
