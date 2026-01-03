'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import Cookies from 'js-cookie';
import { useAuthStore } from '@/stores/auth';
import { ROUTES, STORAGE_KEYS } from '@/config/constants';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Loader2, ShieldCheck } from 'lucide-react';

const loginSchema = z.object({
  email: z
    .string()
    .min(1, 'البريد الإلكتروني مطلوب')
    .email('البريد الإلكتروني غير صالح'),
  password: z
    .string()
    .min(1, 'كلمة المرور مطلوبة')
    .min(8, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const { setAdmin } = useAuthStore();
  const [isLoading, setIsLoading] = useState(false);

  const form = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: '',
      password: '',
    },
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true);

    try {
      // TODO: Replace with actual API call
      // const response = await api.post('/auth/admin/login', data);

      // Simulate login for now
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Mock response
      const mockAdmin = {
        id: '1',
        name: 'مسؤول النظام',
        email: data.email,
        role: 'super_admin' as const,
        permissions: ['all'],
      };

      // Save tokens
      Cookies.set(STORAGE_KEYS.accessToken, 'mock-access-token', { expires: 7 });
      Cookies.set(STORAGE_KEYS.refreshToken, 'mock-refresh-token', {
        expires: 30,
      });

      setAdmin(mockAdmin);
      toast.success('تم تسجيل الدخول بنجاح');
      router.push(ROUTES.dashboard);
    } catch (error) {
      console.error('Login error:', error);
      toast.error('فشل تسجيل الدخول. يرجى التحقق من البيانات المدخلة.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Card className="shadow-lg">
      <CardHeader className="space-y-1 text-center">
        <div className="flex justify-center mb-4">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
            <ShieldCheck className="h-8 w-8 text-primary" />
          </div>
        </div>
        <CardTitle className="text-2xl font-bold">لوحة تحكم المسؤول</CardTitle>
        <CardDescription>
          قم بتسجيل الدخول للوصول إلى لوحة التحكم
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="email"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>البريد الإلكتروني</FormLabel>
                  <FormControl>
                    <Input
                      type="email"
                      placeholder="admin@bagour.com"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="password"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>كلمة المرور</FormLabel>
                  <FormControl>
                    <Input
                      type="password"
                      placeholder="••••••••"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <Button type="submit" className="w-full" disabled={isLoading}>
              {isLoading ? (
                <>
                  <Loader2 className="ml-2 h-4 w-4 animate-spin" />
                  جاري تسجيل الدخول...
                </>
              ) : (
                'تسجيل الدخول'
              )}
            </Button>
          </form>
        </Form>
      </CardContent>
    </Card>
  );
}
