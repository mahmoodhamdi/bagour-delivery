'use client';

import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { toast } from 'sonner';
import Cookies from 'js-cookie';
import { useAuthStore } from '@/stores/auth';
import { ROUTES, STORAGE_KEYS } from '@/config/constants';
import { authApi, getErrorMessage } from '@/lib/api';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  InputOTP,
  InputOTPGroup,
  InputOTPSlot,
} from '@/components/ui/input-otp';
import { Loader2, ArrowRight, CheckCircle2 } from 'lucide-react';

function VerifyEmailForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { setAuth } = useAuthStore();
  const email = searchParams.get('email') || '';

  const [otp, setOtp] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isResending, setIsResending] = useState(false);
  const [isVerified, setIsVerified] = useState(false);
  const [countdown, setCountdown] = useState(60);

  useEffect(() => {
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [countdown]);

  const handleVerify = async () => {
    if (otp.length !== 6) {
      toast.error('يرجى إدخال رمز التحقق كاملاً');
      return;
    }

    setIsLoading(true);

    try {
      const response = await authApi.verifyEmail({
        email,
        otp,
      });

      if (response.success && response.data) {
        const { accessToken, refreshToken, user, restaurant } = response.data;

        // Save tokens
        Cookies.set(STORAGE_KEYS.accessToken, accessToken, { expires: 7 });
        Cookies.set(STORAGE_KEYS.refreshToken, refreshToken, { expires: 30 });

        // Update store
        setAuth(user, restaurant);

        setIsVerified(true);
        toast.success('تم التحقق بنجاح');

        // Redirect after a short delay
        setTimeout(() => {
          router.push(ROUTES.dashboard);
        }, 2000);
      } else {
        toast.error(response.message || 'رمز التحقق غير صحيح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendOtp = async () => {
    if (countdown > 0) return;

    setIsResending(true);

    try {
      const response = await authApi.resendOtp(email);

      if (response.success) {
        toast.success('تم إرسال رمز التحقق مرة أخرى');
        setCountdown(60);
      } else {
        toast.error(response.message || 'فشل في إرسال رمز التحقق');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsResending(false);
    }
  };

  // Auto-submit when OTP is complete
  useEffect(() => {
    if (otp.length === 6 && !isLoading && !isVerified) {
      handleVerify();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [otp]);

  if (!email) {
    return (
      <Card className="shadow-lg">
        <CardContent className="pt-6 text-center">
          <p className="text-muted-foreground">رابط غير صالح</p>
          <Link href={ROUTES.login}>
            <Button className="mt-4">العودة لتسجيل الدخول</Button>
          </Link>
        </CardContent>
      </Card>
    );
  }

  if (isVerified) {
    return (
      <Card className="shadow-lg">
        <CardContent className="py-12 text-center">
          <CheckCircle2 className="mx-auto h-16 w-16 text-green-500" />
          <h2 className="mt-4 text-xl font-bold">تم التحقق بنجاح!</h2>
          <p className="mt-2 text-muted-foreground">
            جاري تحويلك إلى لوحة التحكم...
          </p>
          <Loader2 className="mx-auto mt-4 h-6 w-6 animate-spin text-primary" />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="shadow-lg">
      <CardHeader className="space-y-1 text-center">
        <CardTitle className="text-2xl font-bold">التحقق من البريد الإلكتروني</CardTitle>
        <CardDescription>
          أدخل رمز التحقق المرسل إلى
          <br />
          <span className="font-medium text-foreground">{email}</span>
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="flex justify-center">
          <InputOTP
            maxLength={6}
            value={otp}
            onChange={setOtp}
            disabled={isLoading}
          >
            <InputOTPGroup dir="ltr">
              <InputOTPSlot index={0} />
              <InputOTPSlot index={1} />
              <InputOTPSlot index={2} />
              <InputOTPSlot index={3} />
              <InputOTPSlot index={4} />
              <InputOTPSlot index={5} />
            </InputOTPGroup>
          </InputOTP>
        </div>

        <Button
          onClick={handleVerify}
          className="w-full"
          disabled={isLoading || otp.length !== 6}
        >
          {isLoading ? (
            <>
              <Loader2 className="ml-2 h-4 w-4 animate-spin" />
              جاري التحقق...
            </>
          ) : (
            'تأكيد'
          )}
        </Button>

        <div className="text-center">
          {countdown > 0 ? (
            <p className="text-sm text-muted-foreground">
              إعادة الإرسال بعد {countdown} ثانية
            </p>
          ) : (
            <button
              onClick={handleResendOtp}
              disabled={isResending}
              className="text-sm text-primary hover:underline disabled:opacity-50"
            >
              {isResending ? 'جاري الإرسال...' : 'إعادة إرسال الرمز'}
            </button>
          )}
        </div>
      </CardContent>
      <CardFooter className="flex justify-center">
        <Link
          href={ROUTES.login}
          className="flex items-center text-sm text-muted-foreground hover:text-foreground"
        >
          <ArrowRight className="ml-2 h-4 w-4" />
          العودة لتسجيل الدخول
        </Link>
      </CardFooter>
    </Card>
  );
}

export default function VerifyEmailPage() {
  return (
    <Suspense fallback={<div className="flex items-center justify-center"><Loader2 className="h-8 w-8 animate-spin" /></div>}>
      <VerifyEmailForm />
    </Suspense>
  );
}
