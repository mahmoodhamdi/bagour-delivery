'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/stores/auth';
import { useOrdersStore } from '@/stores/orders';
import { ROUTES } from '@/config/constants';
import { useSocket } from '@/hooks/useSocket';
import {
  SidebarProvider,
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarHeader,
  SidebarFooter,
  SidebarTrigger,
} from '@/components/ui/sidebar';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import {
  LayoutDashboard,
  UtensilsCrossed,
  ShoppingBag,
  BarChart3,
  Settings,
  LogOut,
  Bell,
} from 'lucide-react';

const menuItems = [
  {
    title: 'لوحة التحكم',
    url: '/dashboard',
    icon: LayoutDashboard,
  },
  {
    title: 'الطلبات',
    url: '/dashboard/orders',
    icon: ShoppingBag,
  },
  {
    title: 'القائمة',
    url: '/dashboard/menu',
    icon: UtensilsCrossed,
  },
  {
    title: 'التحليلات',
    url: '/dashboard/analytics',
    icon: BarChart3,
  },
  {
    title: 'الإعدادات',
    url: '/dashboard/settings',
    icon: Settings,
  },
];

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { restaurant, isAuthenticated, isLoading, logout, updateRestaurant } =
    useAuthStore();
  const { pendingOrdersCount } = useOrdersStore();

  // Initialize socket connection for real-time updates
  useSocket();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      // Fall back to the cookie the login flow sets before bouncing —
      // zustand persist sometimes lags the page mount, and the cookie is
      // the source of truth the API client uses anyway.
      const hasCookie = typeof document !== 'undefined' && document.cookie.includes('access_token=');
      if (!hasCookie) {
        router.push(ROUTES.login);
      }
    }
  }, [isAuthenticated, isLoading, router]);

  const handleToggleOpen = () => {
    if (restaurant) {
      updateRestaurant({ isOpen: !restaurant.isOpen });
      // TODO: Call API to update restaurant status
    }
  };

  const handleLogout = () => {
    logout();
    router.push(ROUTES.login);
  };

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    );
  }

  if (!isAuthenticated || !restaurant) {
    return null;
  }

  return (
    <SidebarProvider>
      <div className="flex min-h-screen w-full">
        <Sidebar side="right" collapsible="icon">
          <SidebarHeader className="border-b p-4">
            <div className="flex items-center gap-3">
              <Avatar className="h-10 w-10">
                <AvatarImage src={restaurant.logo} alt={restaurant.name} />
                <AvatarFallback>
                  {restaurant.name.charAt(0)}
                </AvatarFallback>
              </Avatar>
              <div className="flex flex-col group-data-[collapsible=icon]:hidden">
                <span className="font-semibold text-sm truncate max-w-[140px]">
                  {restaurant.name}
                </span>
                <Badge
                  variant={restaurant.isOpen ? 'default' : 'secondary'}
                  className="w-fit text-xs"
                >
                  {restaurant.isOpen ? 'مفتوح' : 'مغلق'}
                </Badge>
              </div>
            </div>
          </SidebarHeader>

          <SidebarContent>
            <SidebarGroup>
              <SidebarGroupLabel>القائمة الرئيسية</SidebarGroupLabel>
              <SidebarGroupContent>
                <SidebarMenu>
                  {menuItems.map((item) => (
                    <SidebarMenuItem key={item.title}>
                      <SidebarMenuButton asChild>
                        <Link href={item.url}>
                          <item.icon className="h-4 w-4" />
                          <span>{item.title}</span>
                        </Link>
                      </SidebarMenuButton>
                    </SidebarMenuItem>
                  ))}
                </SidebarMenu>
              </SidebarGroupContent>
            </SidebarGroup>

            <SidebarGroup>
              <SidebarGroupLabel>حالة المطعم</SidebarGroupLabel>
              <SidebarGroupContent>
                <div className="flex items-center justify-between px-3 py-2 group-data-[collapsible=icon]:justify-center">
                  <span className="text-sm group-data-[collapsible=icon]:hidden">
                    {restaurant.isOpen ? 'مفتوح للطلبات' : 'مغلق حالياً'}
                  </span>
                  <Switch
                    checked={restaurant.isOpen}
                    onCheckedChange={handleToggleOpen}
                  />
                </div>
              </SidebarGroupContent>
            </SidebarGroup>
          </SidebarContent>

          <SidebarFooter className="border-t p-4">
            <SidebarMenu>
              <SidebarMenuItem>
                <SidebarMenuButton onClick={handleLogout}>
                  <LogOut className="h-4 w-4" />
                  <span>تسجيل الخروج</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
            </SidebarMenu>
          </SidebarFooter>
        </Sidebar>

        <div className="flex flex-1 flex-col">
          <header className="sticky top-0 z-10 flex h-14 items-center justify-between border-b bg-background px-4">
            <SidebarTrigger />
            <div className="flex items-center gap-4">
              <Link href="/orders" className="relative rounded-full p-2 hover:bg-muted">
                <Bell className="h-5 w-5" />
                {pendingOrdersCount > 0 && (
                  <span className="absolute -top-1 -left-1 flex h-4 w-4 items-center justify-center rounded-full bg-destructive text-[10px] text-white">
                    {pendingOrdersCount > 9 ? '9+' : pendingOrdersCount}
                  </span>
                )}
              </Link>
            </div>
          </header>

          <main className="flex-1 overflow-auto p-6">{children}</main>
        </div>
      </div>
    </SidebarProvider>
  );
}
