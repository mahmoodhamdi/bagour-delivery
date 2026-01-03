'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
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
  CardFooter,
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
import { Loader2 } from 'lucide-react';

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
  const { setRestaurant } = useAuthStore();
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
      // const response = await api.post('/auth/restaurant/login', data);

      // Simulate login for now
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Mock response
      const mockRestaurant = {
        id: '1',
        name: 'مطعم باجور',
        email: data.email,
        phone: '01234567890',
        status: 'approved' as const,
        isOpen: true,
        address: {
          street: 'شارع الجمهورية',
          area: 'باجور',
          city: 'المنوفية',
        },
        cuisineTypes: ['مصري', 'مشويات'],
        rating: 4.5,
        totalOrders: 150,
      };

      // Save tokens
      Cookies.set(STORAGE_KEYS.accessToken, 'mock-access-token', { expires: 7 });
      Cookies.set(STORAGE_KEYS.refreshToken, 'mock-refresh-token', {
        expires: 30,
      });

      setRestaurant(mockRestaurant);
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
        <CardTitle className="text-2xl font-bold">تسجيل الدخول</CardTitle>
        <CardDescription>
          قم بتسجيل الدخول إلى لوحة تحكم مطعمك
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
                      placeholder="example@restaurant.com"
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
            <div className="flex justify-end">
              <Link
                href="/forgot-password"
                className="text-sm text-primary hover:underline"
              >
                نسيت كلمة المرور؟
              </Link>
            </div>
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
      <CardFooter className="flex justify-center">
        <p className="text-sm text-muted-foreground">
          ليس لديك حساب؟{' '}
          <Link href="/register" className="text-primary hover:underline">
            سجل الآن
          </Link>
        </p>
      </CardFooter>
    </Card>
  );
}
