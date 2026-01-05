/**
 * Export utilities for generating PDF and Excel reports
 */

// Types for export data
interface ExportColumn {
  header: string;
  key: string;
  width?: number;
}

interface ExportData {
  title: string;
  date: string;
  columns: ExportColumn[];
  rows: Record<string, string | number>[];
  summary?: Record<string, string | number>;
}

/**
 * Export data to CSV file (Excel compatible)
 */
export function exportToCSV(data: ExportData): void {
  const BOM = '\uFEFF'; // UTF-8 BOM for Arabic support

  // Build CSV content
  let csvContent = BOM;

  // Add title and date
  csvContent += `${data.title}\n`;
  csvContent += `التاريخ: ${data.date}\n\n`;

  // Add headers
  csvContent += data.columns.map(col => col.header).join(',') + '\n';

  // Add rows
  data.rows.forEach(row => {
    const rowValues = data.columns.map(col => {
      const value = row[col.key];
      // Escape values that contain commas or quotes
      if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
        return `"${value.replace(/"/g, '""')}"`;
      }
      return value ?? '';
    });
    csvContent += rowValues.join(',') + '\n';
  });

  // Add summary if exists
  if (data.summary) {
    csvContent += '\n';
    Object.entries(data.summary).forEach(([key, value]) => {
      csvContent += `${key},${value}\n`;
    });
  }

  // Create and download file
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8' });
  downloadFile(blob, `${data.title.replace(/\s+/g, '_')}_${formatDateForFilename(new Date())}.csv`);
}

/**
 * Export data to printable HTML (for PDF via browser print)
 */
export function exportToPDF(data: ExportData): void {
  // Create HTML content for print
  const htmlContent = `
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
      <meta charset="UTF-8">
      <title>${data.title}</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          padding: 40px;
          color: #333;
        }
        .header {
          text-align: center;
          margin-bottom: 30px;
          border-bottom: 2px solid #333;
          padding-bottom: 20px;
        }
        .header h1 {
          font-size: 24px;
          margin-bottom: 10px;
          color: #1a1a1a;
        }
        .header .date {
          color: #666;
          font-size: 14px;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 20px;
        }
        th, td {
          border: 1px solid #ddd;
          padding: 12px 8px;
          text-align: right;
        }
        th {
          background-color: #f5f5f5;
          font-weight: 600;
          color: #333;
        }
        tr:nth-child(even) {
          background-color: #fafafa;
        }
        .summary {
          margin-top: 30px;
          padding: 20px;
          background: #f5f5f5;
          border-radius: 8px;
        }
        .summary h3 {
          margin-bottom: 15px;
          font-size: 16px;
        }
        .summary-item {
          display: flex;
          justify-content: space-between;
          padding: 8px 0;
          border-bottom: 1px solid #ddd;
        }
        .summary-item:last-child {
          border-bottom: none;
        }
        .footer {
          margin-top: 40px;
          text-align: center;
          color: #666;
          font-size: 12px;
        }
        @media print {
          body { padding: 20px; }
          .no-print { display: none; }
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>${data.title}</h1>
        <div class="date">تاريخ التقرير: ${data.date}</div>
      </div>

      <table>
        <thead>
          <tr>
            ${data.columns.map(col => `<th>${col.header}</th>`).join('')}
          </tr>
        </thead>
        <tbody>
          ${data.rows.map(row => `
            <tr>
              ${data.columns.map(col => `<td>${row[col.key] ?? ''}</td>`).join('')}
            </tr>
          `).join('')}
        </tbody>
      </table>

      ${data.summary ? `
        <div class="summary">
          <h3>ملخص</h3>
          ${Object.entries(data.summary).map(([key, value]) => `
            <div class="summary-item">
              <span>${key}</span>
              <strong>${value}</strong>
            </div>
          `).join('')}
        </div>
      ` : ''}

      <div class="footer">
        تم إنشاء هذا التقرير بواسطة منصة باجور ديليفري
      </div>

      <script>
        window.onload = function() {
          window.print();
        };
      </script>
    </body>
    </html>
  `;

  // Open in new window for printing
  const printWindow = window.open('', '_blank');
  if (printWindow) {
    printWindow.document.write(htmlContent);
    printWindow.document.close();
  }
}

/**
 * Export analytics data
 */
export interface AnalyticsExportData {
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  popularItems: Array<{
    name: string;
    count: number;
    revenue: number;
  }>;
}

export function exportAnalyticsReport(data: AnalyticsExportData, format: 'csv' | 'pdf'): void {
  const today = new Date();
  const dateStr = today.toLocaleDateString('ar-EG', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  // Prepare export data
  const exportData: ExportData = {
    title: 'تقرير التحليلات - المطعم',
    date: dateStr,
    columns: [
      { header: 'البند', key: 'item' },
      { header: 'القيمة', key: 'value' },
    ],
    rows: [
      { item: 'إجمالي الطلبات', value: data.totalOrders },
      { item: 'إجمالي الإيرادات', value: `${data.totalRevenue.toLocaleString()} ج.م` },
      { item: 'متوسط قيمة الطلب', value: `${data.averageOrderValue.toLocaleString()} ج.م` },
      { item: '', value: '' }, // Separator
      { item: 'الأصناف الأكثر طلباً:', value: '' },
      ...data.popularItems.slice(0, 10).map((item, idx) => ({
        item: `${idx + 1}. ${item.name}`,
        value: `${item.count} وحدة - ${item.revenue.toLocaleString()} ج.م`,
      })),
    ],
    summary: {
      'إجمالي الإيرادات': `${data.totalRevenue.toLocaleString()} ج.م`,
      'إجمالي الطلبات': data.totalOrders,
      'متوسط قيمة الطلب': `${data.averageOrderValue.toLocaleString()} ج.م`,
    },
  };

  // Export based on format
  if (format === 'csv') {
    exportToCSV(exportData);
  } else {
    exportToPDF(exportData);
  }
}

/**
 * Export orders report
 */
export interface OrderExportData {
  orders: Array<{
    orderNumber: string;
    customerName: string;
    total: number;
    status: string;
    createdAt: string;
  }>;
  summary?: {
    totalOrders: number;
    totalRevenue: number;
  };
}

export function exportOrdersReport(data: OrderExportData, format: 'csv' | 'pdf'): void {
  const today = new Date();
  const dateStr = today.toLocaleDateString('ar-EG', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  const exportData: ExportData = {
    title: 'تقرير الطلبات - المطعم',
    date: dateStr,
    columns: [
      { header: 'رقم الطلب', key: 'orderNumber' },
      { header: 'العميل', key: 'customerName' },
      { header: 'المبلغ', key: 'total' },
      { header: 'الحالة', key: 'status' },
      { header: 'التاريخ', key: 'createdAt' },
    ],
    rows: data.orders.map(order => ({
      orderNumber: order.orderNumber,
      customerName: order.customerName,
      total: `${order.total.toLocaleString()} ج.م`,
      status: order.status,
      createdAt: order.createdAt,
    })),
    summary: data.summary ? {
      'إجمالي الطلبات': data.summary.totalOrders,
      'إجمالي الإيرادات': `${data.summary.totalRevenue.toLocaleString()} ج.م`,
    } : undefined,
  };

  if (format === 'csv') {
    exportToCSV(exportData);
  } else {
    exportToPDF(exportData);
  }
}

// Helper functions
function downloadFile(blob: Blob, filename: string): void {
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

function formatDateForFilename(date: Date): string {
  return date.toISOString().split('T')[0];
}
