import { Resend } from 'resend';
import { config } from '@config/index';

const resend = new Resend(config.resend.apiKey);

interface EmailOptions {
  to: string;
  subject: string;
  html: string;
}

/**
 * Email Service using Resend API
 * Handles OTP verification, password reset, welcome emails, and order notifications
 */
class EmailService {
  /**
   * Send raw email
   */
  private async sendEmail({ to, subject, html }: EmailOptions): Promise<void> {
    try {
      await resend.emails.send({
        from: config.resend.fromEmail,
        to,
        subject,
        html,
      });
    } catch (error) {
      console.error('Failed to send email:', error);
      throw new Error('فشل في إرسال البريد الإلكتروني');
    }
  }

  /**
   * Send OTP for email verification
   */
  async sendVerificationOTP(email: string, otp: string, userName?: string): Promise<void> {
    const subject = 'تأكيد البريد الإلكتروني - Bagour Delivery';
    const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تأكيد البريد الإلكتروني</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4;">
  <table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-color: #f4f4f4; padding: 20px;">
    <tr>
      <td align="center">
        <table cellpadding="0" cellspacing="0" border="0" width="600" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 600;">Bagour Delivery</h1>
              <p style="color: #ffffff; margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">منصة توصيل الطعام</p>
            </td>
          </tr>

          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              ${userName ? `<p style="color: #333; font-size: 18px; margin: 0 0 20px 0;">مرحباً ${userName}،</p>` : ''}

              <p style="color: #555; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                شكراً لتسجيلك في Bagour Delivery. لإكمال عملية التسجيل، يرجى استخدام رمز التحقق التالي:
              </p>

              <!-- OTP Box -->
              <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr>
                  <td align="center" style="padding: 30px 0;">
                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; padding: 20px 40px; display: inline-block;">
                      <p style="color: #ffffff; font-size: 14px; margin: 0 0 8px 0; opacity: 0.9;">رمز التحقق الخاص بك</p>
                      <h2 style="color: #ffffff; font-size: 42px; font-weight: 700; margin: 0; letter-spacing: 8px; font-family: 'Courier New', monospace;">${otp}</h2>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="color: #555; font-size: 14px; line-height: 1.6; margin: 20px 0; text-align: center;">
                صالح لمدة <strong>10 دقائق</strong>
              </p>

              <div style="background-color: #fff3cd; border-right: 4px solid #ffc107; padding: 15px; border-radius: 4px; margin: 20px 0;">
                <p style="color: #856404; font-size: 14px; margin: 0; line-height: 1.5;">
                  ⚠️ <strong>تنبيه أمني:</strong> إذا لم تقم بطلب هذا الرمز، يرجى تجاهل هذا البريد الإلكتروني.
                </p>
              </div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
              <p style="color: #6c757d; font-size: 14px; margin: 0 0 10px 0;">
                هل تحتاج إلى مساعدة؟ <a href="mailto:support@bagour-delivery.com" style="color: #667eea; text-decoration: none;">تواصل معنا</a>
              </p>
              <p style="color: #adb5bd; font-size: 12px; margin: 0;">
                © 2025 Bagour Delivery. جميع الحقوق محفوظة.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;

    await this.sendEmail({ to: email, subject, html });
  }

  /**
   * Send OTP for password reset
   */
  async sendPasswordResetOTP(email: string, otp: string, userName?: string): Promise<void> {
    const subject = 'إعادة تعيين كلمة المرور - Bagour Delivery';
    const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>إعادة تعيين كلمة المرور</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4;">
  <table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-color: #f4f4f4; padding: 20px;">
    <tr>
      <td align="center">
        <table cellpadding="0" cellspacing="0" border="0" width="600" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 40px 20px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 600;">Bagour Delivery</h1>
              <p style="color: #ffffff; margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">إعادة تعيين كلمة المرور</p>
            </td>
          </tr>

          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              ${userName ? `<p style="color: #333; font-size: 18px; margin: 0 0 20px 0;">مرحباً ${userName}،</p>` : ''}

              <p style="color: #555; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك. استخدم الرمز التالي لإعادة تعيين كلمة المرور:
              </p>

              <!-- OTP Box -->
              <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr>
                  <td align="center" style="padding: 30px 0;">
                    <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: 12px; padding: 20px 40px; display: inline-block;">
                      <p style="color: #ffffff; font-size: 14px; margin: 0 0 8px 0; opacity: 0.9;">رمز إعادة التعيين</p>
                      <h2 style="color: #ffffff; font-size: 42px; font-weight: 700; margin: 0; letter-spacing: 8px; font-family: 'Courier New', monospace;">${otp}</h2>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="color: #555; font-size: 14px; line-height: 1.6; margin: 20px 0; text-align: center;">
                صالح لمدة <strong>15 دقيقة</strong>
              </p>

              <div style="background-color: #f8d7da; border-right: 4px solid #dc3545; padding: 15px; border-radius: 4px; margin: 20px 0;">
                <p style="color: #721c24; font-size: 14px; margin: 0; line-height: 1.5;">
                  🔒 <strong>تحذير أمني:</strong> إذا لم تطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذا البريد وتأمين حسابك فوراً.
                </p>
              </div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
              <p style="color: #6c757d; font-size: 14px; margin: 0 0 10px 0;">
                هل تحتاج إلى مساعدة؟ <a href="mailto:support@bagour-delivery.com" style="color: #f5576c; text-decoration: none;">تواصل معنا</a>
              </p>
              <p style="color: #adb5bd; font-size: 12px; margin: 0;">
                © 2025 Bagour Delivery. جميع الحقوق محفوظة.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;

    await this.sendEmail({ to: email, subject, html });
  }

  /**
   * Send welcome email after successful registration
   */
  async sendWelcomeEmail(email: string, userName: string, role: string): Promise<void> {
    const roleText = {
      customer: 'عميل',
      restaurant: 'مطعم',
      driver: 'سائق توصيل',
      admin: 'مدير',
    }[role] || 'مستخدم';

    const subject = `مرحباً بك في Bagour Delivery! 🎉`;
    const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>مرحباً بك</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4;">
  <table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-color: #f4f4f4; padding: 20px;">
    <tr>
      <td align="center">
        <table cellpadding="0" cellspacing="0" border="0" width="600" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); padding: 40px 20px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 32px; font-weight: 600;">🎉 مرحباً بك!</h1>
              <p style="color: #ffffff; margin: 10px 0 0 0; font-size: 18px; opacity: 0.95;">في عائلة Bagour Delivery</p>
            </td>
          </tr>

          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              <p style="color: #333; font-size: 20px; margin: 0 0 15px 0; font-weight: 600;">أهلاً ${userName}! 👋</p>

              <p style="color: #555; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                يسعدنا انضمامك إلى منصة Bagour Delivery كـ <strong>${roleText}</strong>. نحن هنا لنقدم لك أفضل تجربة توصيل طعام في مدينة باقور.
              </p>

              <div style="background-color: #e7f5ff; border-right: 4px solid #0984e3; padding: 20px; border-radius: 4px; margin: 25px 0;">
                <h3 style="color: #0984e3; margin: 0 0 15px 0; font-size: 18px;">✨ ماذا بعد؟</h3>
                ${role === 'customer' ? `
                  <ul style="color: #555; font-size: 15px; line-height: 1.8; margin: 0; padding-right: 20px;">
                    <li>تصفح المطاعم المتاحة في منطقتك</li>
                    <li>اطلب وجباتك المفضلة بسهولة</li>
                    <li>تتبع طلبك في الوقت الفعلي</li>
                    <li>استمتع بعروض وخصومات حصرية</li>
                  </ul>
                ` : role === 'restaurant' ? `
                  <ul style="color: #555; font-size: 15px; line-height: 1.8; margin: 0; padding-right: 20px;">
                    <li>أكمل معلومات مطعمك وساعات العمل</li>
                    <li>أضف قائمة الطعام والأسعار</li>
                    <li>استقبل وإدارة الطلبات بسهولة</li>
                    <li>تابع أداء مطعمك عبر لوحة التحكم</li>
                  </ul>
                ` : role === 'driver' ? `
                  <ul style="color: #555; font-size: 15px; line-height: 1.8; margin: 0; padding-right: 20px;">
                    <li>أكمل بياناتك الشخصية ومعلومات السيارة</li>
                    <li>ابدأ استقبال طلبات التوصيل</li>
                    <li>تتبع أرباحك اليومية والشهرية</li>
                    <li>احصل على تقييمات من العملاء</li>
                  </ul>
                ` : `
                  <ul style="color: #555; font-size: 15px; line-height: 1.8; margin: 0; padding-right: 20px;">
                    <li>إدارة المنصة بالكامل</li>
                    <li>مراقبة الطلبات والمستخدمين</li>
                    <li>متابعة الإحصائيات والتقارير</li>
                  </ul>
                `}
              </div>

              <p style="color: #555; font-size: 15px; line-height: 1.6; margin: 25px 0 0 0;">
                نحن دائماً هنا لمساعدتك. إذا كان لديك أي استفسار، لا تتردد في التواصل معنا.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
              <p style="color: #6c757d; font-size: 14px; margin: 0 0 10px 0;">
                هل تحتاج إلى مساعدة؟ <a href="mailto:support@bagour-delivery.com" style="color: #43e97b; text-decoration: none;">تواصل معنا</a>
              </p>
              <p style="color: #adb5bd; font-size: 12px; margin: 0;">
                © 2025 Bagour Delivery. جميع الحقوق محفوظة.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;

    await this.sendEmail({ to: email, subject, html });
  }

  /**
   * Send order confirmation email
   */
  async sendOrderConfirmation(
    email: string,
    orderNumber: string,
    totalAmount: number,
    items: Array<{ name: string; quantity: number; price: number }>
  ): Promise<void> {
    const subject = `تأكيد الطلب #${orderNumber} - Bagour Delivery`;

    const itemsHtml = items.map(item => `
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #e9ecef; color: #555;">${item.name}</td>
        <td style="padding: 10px; border-bottom: 1px solid #e9ecef; color: #555; text-align: center;">${item.quantity}</td>
        <td style="padding: 10px; border-bottom: 1px solid #e9ecef; color: #555; text-align: left;">${item.price} ج.م</td>
      </tr>
    `).join('');

    const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تأكيد الطلب</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4;">
  <table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-color: #f4f4f4; padding: 20px;">
    <tr>
      <td align="center">
        <table cellpadding="0" cellspacing="0" border="0" width="600" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 40px 20px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 600;">✅ تم تأكيد طلبك</h1>
              <p style="color: #ffffff; margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">رقم الطلب: #${orderNumber}</p>
            </td>
          </tr>

          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              <p style="color: #555; font-size: 16px; line-height: 1.6; margin: 0 0 25px 0;">
                شكراً لك! تم استلام طلبك بنجاح وجاري تجهيزه الآن.
              </p>

              <h3 style="color: #333; margin: 0 0 15px 0; font-size: 18px;">تفاصيل الطلب:</h3>

              <table cellpadding="0" cellspacing="0" border="0" width="100%" style="border: 1px solid #e9ecef; border-radius: 4px; overflow: hidden;">
                <thead>
                  <tr style="background-color: #f8f9fa;">
                    <th style="padding: 12px; text-align: right; color: #333; font-weight: 600;">الصنف</th>
                    <th style="padding: 12px; text-align: center; color: #333; font-weight: 600;">الكمية</th>
                    <th style="padding: 12px; text-align: left; color: #333; font-weight: 600;">السعر</th>
                  </tr>
                </thead>
                <tbody>
                  ${itemsHtml}
                  <tr style="background-color: #f8f9fa;">
                    <td colspan="2" style="padding: 15px; text-align: right; color: #333; font-weight: 600; font-size: 16px;">الإجمالي</td>
                    <td style="padding: 15px; text-align: left; color: #f5576c; font-weight: 700; font-size: 18px;">${totalAmount} ج.م</td>
                  </tr>
                </tbody>
              </table>

              <div style="background-color: #d1f2eb; border-right: 4px solid #00b894; padding: 15px; border-radius: 4px; margin: 25px 0;">
                <p style="color: #00695c; font-size: 14px; margin: 0; line-height: 1.5;">
                  📱 يمكنك تتبع حالة طلبك في الوقت الفعلي عبر التطبيق
                </p>
              </div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
              <p style="color: #6c757d; font-size: 14px; margin: 0 0 10px 0;">
                هل تحتاج إلى مساعدة؟ <a href="mailto:support@bagour-delivery.com" style="color: #f5576c; text-decoration: none;">تواصل معنا</a>
              </p>
              <p style="color: #adb5bd; font-size: 12px; margin: 0;">
                © 2025 Bagour Delivery. جميع الحقوق محفوظة.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;

    await this.sendEmail({ to: email, subject, html });
  }
}

export const emailService = new EmailService();
