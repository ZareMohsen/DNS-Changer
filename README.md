# DNS-Changer
این کد یک اسکریپت PowerShell است که به کاربران اجازه می‌دهد تنظیمات DNS کارت شبکه‌های خود را تغییر دهند

تغییر DNS در ویندوز با PowerShell
این پروژه یک اسکریپت PowerShell است که به شما امکان می‌دهد تنظیمات DNS کارت شبکه‌های خود را در ویندوز تغییر دهید. با استفاده از این اسکریپت، می‌توانید سرورهای DNS مختلف (مانند Cloudflare, Google, Shecan, OpenDNS, Quad9) را تست کرده و یکی از آن‌ها را انتخاب کنید یا تنظیمات DNS را به حالت خودکار (DHCP) بازگردانید.

ویژگی‌ها
لیست کردن تمام کارت‌های شبکه موجود در سیستم.

نمایش اطلاعات کارت شبکه انتخاب شده (وضعیت، آدرس IP، دروازه پیش‌فرض).

تست سرعت پاسخ‌دهی سرورهای DNS مختلف.

تغییر DNS کارت شبکه به یکی از گزینه‌های پیش‌فرض یا بازگشت به حالت DHCP.

امکان اجرای مجدد تست DNS یا تغییر کارت شبکه.

پیش‌نیازها
سیستم عامل ویندوز

PowerShell با دسترسی Administrator

نحوه استفاده
اسکریپت را دانلود کنید یا محتوای آن را کپی کنید.

PowerShell را با دسترسی Administrator اجرا کنید.

اسکریپت را اجرا کنید:

powershell
Copy
.\Change-DNS.ps1
دستورالعمل‌های روی صفحه را دنبال کنید:

یک کارت شبکه از لیست نمایش داده شده انتخاب کنید.

یکی از گزینه‌های DNS را انتخاب کنید یا تنظیمات را به حالت DHCP بازگردانید.

در صورت نیاز، تست سرعت DNS را دوباره اجرا کنید.

گزینه‌های DNS پیش‌فرض
Cloudflare: 1.1.1.1, 1.0.0.1

Google: 8.8.8.8, 8.8.4.4

Shecan: 178.22.122.100, 185.51.200.2

OpenDNS: 208.67.222.222, 208.67.220.220

Quad9: 9.9.9.9, 149.112.112.112

مثال‌ها
تغییر DNS به Cloudflare:

Copy
Select a network adapter by number: 1
Please select a number (1-8): 1
خروجی:

Copy
Changing DNS settings for adapter: Ethernet
DNS changed to: 1.1.1.1, 1.0.0.1
بازگشت به DHCP:

Copy
Please select a number (1-8): 6
خروجی:

Copy
DNS restored to automatic (DHCP).
Resetting Winsock...
Successfully reset the Winsock Catalog.
Flushing DNS cache...
Releasing current IP address...
Renewing IP address...
مشارکت
اگر می‌خواهید در بهبود این پروژه مشارکت کنید، لطفاً مراحل زیر را دنبال کنید:

پروژه را Fork کنید.

یک Branch جدید ایجاد کنید (git checkout -b feature/YourFeatureName).

تغییرات خود را Commit کنید (git commit -m 'Add some feature').

تغییرات را Push کنید (git push origin feature/YourFeatureName).

یک Pull Request ایجاد کنید.
