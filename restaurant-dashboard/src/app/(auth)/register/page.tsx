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
import { authApi, getErrorMessage } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
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
import { Loader2, Eye, EyeOff, ChevronRight, ChevronLeft } from 'lucide-react';

const cuisineOptions = [
  'مصري',
  'مشويات',
  'فطائر',
  'بيتزا',
  'برجر',
  'شاورما',
  'مأكولات بحرية',
  'حلويات',
  'مشروبات',
  'وجبات سريعة',
];

const registerSchema = z.object({
  // Step 1: Basic Info
  name: z.string().min(3, 'اسم المطعم يجب أن يكون 3 أحرف على الأقل'),
  nameEn: z.string().optional(),
  email: z.string().email('البريد الإلكتروني غير صالح'),
  phone: z
    .string()
    .min(11, 'رقم الهاتف يجب أن يكون 11 رقم')
    .regex(/^01[0125][0-9]{8}$/, 'رقم الهاتف غير صالح'),
  password: z
    .string()
    .min(8, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل')
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      'كلمة المرور يجب أن تحتوي على حرف كبير وحرف صغير ورقم'
    ),
  confirmPassword: z.string(),

  // Step 2: Address
  street: z.string().min(5, 'العنوان يجب أن يكون 5 أحرف على الأقل'),
  area: z.string().min(2, 'المنطقة مطلوبة'),
  city: z.string(),

  // Step 3: Restaurant Details
  cuisineTypes: z.array(z.string()).min(1, 'اختر نوع واحد على الأقل'),
  deliveryFee: z.number().min(0, 'رسوم التوصيل يجب أن تكون 0 أو أكثر').optional(),
  minimumOrder: z.number().min(0, 'الحد الأدنى للطلب يجب أن يكون 0 أو أكثر').optional(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'كلمات المرور غير متطابقة',
  path: ['confirmPassword'],
});

type RegisterFormData = z.infer<typeof registerSchema>;

export default function RegisterPage() {
  const router = useRouter();
  const { setAuth } = useAuthStore();
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [step, setStep] = useState(1);

  const form = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      name: '',
      nameEn: '',
      email: '',
      phone: '',
      password: '',
      confirmPassword: '',
      street: '',
      area: 'باجور',
      city: 'المنوفية',
      cuisineTypes: [],
      deliveryFee: 10,
      minimumOrder: 30,
    },
  });

  const validateStep = async (currentStep: number) => {
    let fieldsToValidate: (keyof RegisterFormData)[] = [];

    switch (currentStep) {
      case 1:
        fieldsToValidate = ['name', 'email', 'phone', 'password', 'confirmPassword'];
        break;
      case 2:
        fieldsToValidate = ['street', 'area'];
        break;
      case 3:
        fieldsToValidate = ['cuisineTypes'];
        break;
    }

    const result = await form.trigger(fieldsToValidate);
    return result;
  };

  const nextStep = async () => {
    const isValid = await validateStep(step);
    if (isValid && step < 3) {
      setStep(step + 1);
    }
  };

  const prevStep = () => {
    if (step > 1) {
      setStep(step - 1);
    }
  };

  const onSubmit = async (data: RegisterFormData) => {
    setIsLoading(true);

    try {
      const response = await authApi.register({
        name: data.name,
        nameEn: data.nameEn,
        email: data.email,
        phone: data.phone,
        password: data.password,
        address: {
          street: data.street,
          area: data.area,
          city: data.city,
        },
        cuisineTypes: data.cuisineTypes,
        deliveryFee: data.deliveryFee,
        minimumOrder: data.minimumOrder,
      });

      if (response.success && response.data) {
        const { accessToken, refreshToken, user, restaurant } = response.data;

        // Save tokens
        Cookies.set(STORAGE_KEYS.accessToken, accessToken, { expires: 7 });
        Cookies.set(STORAGE_KEYS.refreshToken, refreshToken, { expires: 30 });

        // Update store
        setAuth(user, restaurant);

        toast.success('تم إنشاء الحساب بنجاح');

        // Redirect to OTP verification
        router.push(`/verify-otp?email=${encodeURIComponent(data.email)}&type=registration`);
      } else {
        toast.error(response.message || 'فشل في إنشاء الحساب');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsLoading(false);
    }
  };

  const toggleCuisine = (cuisine: string) => {
    const current = form.getValues('cuisineTypes');
    if (current.includes(cuisine)) {
      form.setValue('cuisineTypes', current.filter((c) => c !== cuisine));
    } else {
      form.setValue('cuisineTypes', [...current, cuisine]);
    }
  };

  return (
    <Card className="shadow-lg">
      <CardHeader className="space-y-1 text-center">
        <CardTitle className="text-2xl font-bold">تسجيل مطعم جديد</CardTitle>
        <CardDescription>
          أنشئ حسابًا لمطعمك وابدأ في استقبال الطلبات
        </CardDescription>
        {/* Progress Steps */}
        <div className="flex items-center justify-center gap-2 pt-4">
          {[1, 2, 3].map((s) => (
            <div
              key={s}
              className={`flex h-8 w-8 items-center justify-center rounded-full text-sm font-medium ${
                s === step
                  ? 'bg-primary text-primary-foreground'
                  : s < step
                  ? 'bg-primary/20 text-primary'
                  : 'bg-muted text-muted-foreground'
              }`}
            >
              {s}
            </div>
          ))}
        </div>
        <p className="text-sm text-muted-foreground">
          {step === 1 && 'المعلومات الأساسية'}
          {step === 2 && 'عنوان المطعم'}
          {step === 3 && 'تفاصيل المطعم'}
        </p>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            {/* Step 1: Basic Info */}
            {step === 1 && (
              <>
                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>اسم المطعم</FormLabel>
                      <FormControl>
                        <Input
                          placeholder="مطعم باجور"
                          disabled={isLoading}
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="nameEn"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>اسم المطعم بالإنجليزية (اختياري)</FormLabel>
                      <FormControl>
                        <Input
                          placeholder="Bagour Restaurant"
                          disabled={isLoading}
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
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
                          disabled={isLoading}
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="phone"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>رقم الهاتف</FormLabel>
                      <FormControl>
                        <Input
                          type="tel"
                          placeholder="01234567890"
                          disabled={isLoading}
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
                        <div className="relative">
                          <Input
                            type={showPassword ? 'text' : 'password'}
                            placeholder="••••••••"
                            disabled={isLoading}
                            {...field}
                          />
                          <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                          >
                            {showPassword ? (
                              <EyeOff className="h-4 w-4" />
                            ) : (
                              <Eye className="h-4 w-4" />
                            )}
                          </button>
                        </div>
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="confirmPassword"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>تأكيد كلمة المرور</FormLabel>
                      <FormControl>
                        <div className="relative">
                          <Input
                            type={showConfirmPassword ? 'text' : 'password'}
                            placeholder="••••••••"
                            disabled={isLoading}
                            {...field}
                          />
                          <button
                            type="button"
                            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                            className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                          >
                            {showConfirmPassword ? (
                              <EyeOff className="h-4 w-4" />
                            ) : (
                              <Eye className="h-4 w-4" />
                            )}
                          </button>
                        </div>
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </>
            )}

            {/* Step 2: Address */}
            {step === 2 && (
              <>
                <FormField
                  control={form.control}
                  name="street"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>العنوان التفصيلي</FormLabel>
                      <FormControl>
                        <Textarea
                          placeholder="شارع الجمهورية، بجوار المسجد الكبير"
                          disabled={isLoading}
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="area"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>المنطقة</FormLabel>
                      <FormControl>
                        <Input
                          placeholder="باجور"
                          disabled={isLoading}
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="city"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>المحافظة</FormLabel>
                      <FormControl>
                        <Input
                          disabled
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </>
            )}

            {/* Step 3: Restaurant Details */}
            {step === 3 && (
              <>
                <FormField
                  control={form.control}
                  name="cuisineTypes"
                  render={() => (
                    <FormItem>
                      <FormLabel>نوع المطبخ</FormLabel>
                      <div className="flex flex-wrap gap-2">
                        {cuisineOptions.map((cuisine) => (
                          <button
                            key={cuisine}
                            type="button"
                            onClick={() => toggleCuisine(cuisine)}
                            className={`rounded-full px-3 py-1 text-sm transition-colors ${
                              form.watch('cuisineTypes').includes(cuisine)
                                ? 'bg-primary text-primary-foreground'
                                : 'bg-muted hover:bg-muted/80'
                            }`}
                          >
                            {cuisine}
                          </button>
                        ))}
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <div className="grid grid-cols-2 gap-4">
                  <FormField
                    control={form.control}
                    name="deliveryFee"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>رسوم التوصيل (جنيه)</FormLabel>
                        <FormControl>
                          <Input
                            type="number"
                            placeholder="10"
                            disabled={isLoading}
                            value={field.value ?? ''}
                            onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name="minimumOrder"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>الحد الأدنى للطلب (جنيه)</FormLabel>
                        <FormControl>
                          <Input
                            type="number"
                            placeholder="30"
                            disabled={isLoading}
                            value={field.value ?? ''}
                            onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
              </>
            )}

            {/* Navigation Buttons */}
            <div className="flex justify-between gap-4 pt-4">
              {step > 1 ? (
                <Button
                  type="button"
                  variant="outline"
                  onClick={prevStep}
                  disabled={isLoading}
                >
                  <ChevronRight className="ml-2 h-4 w-4" />
                  السابق
                </Button>
              ) : (
                <div />
              )}
              {step < 3 ? (
                <Button type="button" onClick={nextStep} disabled={isLoading}>
                  التالي
                  <ChevronLeft className="mr-2 h-4 w-4" />
                </Button>
              ) : (
                <Button type="submit" disabled={isLoading}>
                  {isLoading ? (
                    <>
                      <Loader2 className="ml-2 h-4 w-4 animate-spin" />
                      جاري التسجيل...
                    </>
                  ) : (
                    'تسجيل المطعم'
                  )}
                </Button>
              )}
            </div>
          </form>
        </Form>
      </CardContent>
      <CardFooter className="flex justify-center">
        <p className="text-sm text-muted-foreground">
          لديك حساب بالفعل؟{' '}
          <Link href={ROUTES.login} className="text-primary hover:underline">
            تسجيل الدخول
          </Link>
        </p>
      </CardFooter>
    </Card>
  );
}
