import type { MenuAddon, MenuItem, MenuOption } from "@bagour/types";

export interface SelectedChoice {
  optionName: string;
  choice: string;
  price: number;
}

export interface SelectedAddon {
  name: string;
  price: number;
}

export interface CartItemBuilder {
  menuItem: MenuItem;
  quantity: number;
  addons: SelectedAddon[];
  options: SelectedChoice[];
  specialInstructions?: string;
}

/**
 * Compute the per-item total for a configured menu item:
 *   (base + sum of options + sum of addons) * quantity.
 * Honours discountPrice when present.
 */
export function computeItemTotal(builder: CartItemBuilder): number {
  const base = builder.menuItem.discountPrice ?? builder.menuItem.price;
  const optionsTotal = builder.options.reduce((sum, o) => sum + o.price, 0);
  const addonsTotal = builder.addons.reduce((sum, a) => sum + a.price, 0);
  return (base + optionsTotal + addonsTotal) * builder.quantity;
}

/**
 * Validation: every required option group must have a selection.
 * Returns an array of option names that are missing.
 */
export function findMissingRequiredOptions(
  options: MenuOption[],
  selected: SelectedChoice[],
): string[] {
  const missing: string[] = [];
  for (const opt of options) {
    if (!opt.required) continue;
    const has = selected.some((s) => s.optionName === opt.name);
    if (!has) missing.push(opt.name);
  }
  return missing;
}

/** True when an addon is still available + not already selected. */
export function canAddAddon(addon: MenuAddon, selected: SelectedAddon[]): boolean {
  return addon.isAvailable && !selected.some((s) => s.name === addon.name);
}
