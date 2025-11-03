// Wait for DOM to be fully loaded
document.addEventListener("DOMContentLoaded", function() {
    // Initialize UI components
    initializeSidebar();
    initializeChart();
    initializeExportPDF();
    initializePeriodFilter();
});

// Sidebar functionality
function initializeSidebar() {
    const menuBtn = document.getElementById("menu-toggle");
    const sidebar = document.getElementById("sidebar");

    if (menuBtn && sidebar) {
        menuBtn.addEventListener("click", () => {
            sidebar.classList.toggle("active");
        });
    }
}

// Chart state
let currentChart = null;
let currentPeriod = 'day';

// Sample data for different periods
const chartData = {
    day: {
        labels: ["12am", "4am", "8am", "12pm", "4pm", "8pm"],
        data: [30, 45, 120, 160, 180, 140]
    },
    month: {
        labels: ["Week 1", "Week 2", "Week 3", "Week 4"],
        data: [450, 680, 720, 850]
    },
    year: {
        labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        data: [2800, 3200, 3800, 3600, 4200, 4500, 4800, 5200, 5600, 5400, 5800, 6200]
    }
};

// Initialize period filter buttons
function initializePeriodFilter() {
    const filterButtons = document.querySelectorAll('.filter-btn');
    if (!filterButtons.length) return;

    filterButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            // Update active state
            filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            // Update chart
            const period = btn.dataset.period;
            updateChart(period);
        });
    });
}

// Chart initialization
function initializeChart() {
    const ctx = document.getElementById("transactionChart");
    if (!ctx) return;

    currentChart = new Chart(ctx, {
        type: "line",
        data: {
            labels: chartData.day.labels,
            datasets: [{
                label: "Transactions",
                data: chartData.day.data,
                borderColor: "#00e6ff",
                tension: 0.4,
                fill: true,
                backgroundColor: "rgba(0, 230, 255, 0.1)",
                pointRadius: 5,
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: { color: "#fff" }
                },
                title: {
                    display: true,
                    text: 'Daily Transactions',
                    color: '#fff',
                    font: {
                        size: 16
                    }
                }
            },
            scales: {
                x: { 
                    ticks: { color: "#ccc" },
                    grid: {
                        color: "rgba(255, 255, 255, 0.1)"
                    }
                },
                y: { 
                    ticks: { color: "#ccc" },
                    grid: {
                        color: "rgba(255, 255, 255, 0.1)"
                    }
                }
            },
            animations: {
                tension: {
                    duration: 1000,
                    easing: 'linear'
                }
            }
        }
    });
}

// Function to update chart based on selected period
function updateChart(period) {
    if (!currentChart || !chartData[period]) return;
    
    currentPeriod = period;
    
    // Update chart data
    currentChart.data.labels = chartData[period].labels;
    currentChart.data.datasets[0].data = chartData[period].data;
    
    // Update chart title
    currentChart.options.plugins.title.text = `${period.charAt(0).toUpperCase() + period.slice(1)}ly Transactions`;
    
    // Refresh chart
    currentChart.update();
}

// PDF Export functionality
function initializeExportPDF() {
    const exportBtn = document.getElementById("exportBtn");
    if (!exportBtn) return;

    exportBtn.addEventListener("click", async function() {
        try {
            const { jsPDF } = window.jspdf;
            const pdf = new jsPDF({
                orientation: "portrait",
                unit: "pt",
                format: "a4"
            });

            // Add title and date
            pdf.setFontSize(18);
            pdf.text("Telemedicine USSD Dashboard Report", 40, 50);
            
            pdf.setFontSize(12);
            pdf.text("Generated on: " + new Date().toLocaleString(), 40, 70);

            // Add chart image
            const chartCanvas = document.getElementById("transactionChart");
            if (chartCanvas) {
                const chartImage = await html2canvas(chartCanvas);
                const chartData = chartImage.toDataURL("image/png");
                pdf.addImage(chartData, "PNG", 40, 100, 520, 300);
            }

            // Add period information
            pdf.setFontSize(12);
            pdf.text(`Period: ${currentPeriod.charAt(0).toUpperCase() + currentPeriod.slice(1)}`, 40, 410);

            // Add summary statistics
            pdf.setFontSize(14);
            pdf.text("Summary Insights:", 40, 420);

            pdf.setFontSize(12);
            const stats = [
                { label: "Transactions Today", value: window.totalToday },
                { label: "This Month", value: window.totalMonth },
                { label: "This Year", value: window.totalYear },
                { label: "Successful Transactions", value: window.successCount + "%" },
                { label: "Failed Transactions", value: window.failedCount + "%" }
            ];

            stats.forEach((stat, index) => {
                pdf.text(`• ${stat.label}: ${stat.value}`, 60, 440 + (index * 20));
            });

            // Save the PDF
            pdf.save("Telemedicine_Dashboard_Report.pdf");
        } catch (error) {
            console.error("Error generating PDF:", error);
        }
    });
}
