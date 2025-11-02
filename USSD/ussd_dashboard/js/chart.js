let chartInstance = null;

function filterData(range) {
    const ctx = document.getElementById("transactionChart").getContext("2d");

    // Example data (replace with live DB fetch if needed)
    let labels = [];
    let values = [];

    if (range === 'day') {
        labels = ['8 AM', '10 AM', '12 PM', '2 PM', '4 PM', '6 PM'];
        values = [5, 10, 7, 12, 8, 15];
    } else if (range === 'month') {
        labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        values = [50, 60, 40, 70];
    } else {
        labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
        values = [200, 250, 300, 280, 350, 400];
    }

    if (chartInstance) chartInstance.destroy();

    chartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Transactions',
                data: values,
                borderColor: '#00adb5',
                borderWidth: 2,
                fill: false,
                tension: 0.3,
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: true }
            }
        }
    });
}

// 🧾 Export PDF Function
document.getElementById("exportBtn").addEventListener("click", async function() {
    const { jsPDF } = window.jspdf;
    const pdf = new jsPDF({
        orientation: "portrait",
        unit: "pt",
        format: "a4",
    });

    pdf.setFontSize(18);
    pdf.text("Telemedicine USSD Dashboard Report", 40, 50);

    pdf.setFontSize(12);
    pdf.text("Generated on: " + new Date().toLocaleString(), 40, 70);

    // Capture chart
    const chartCanvas = document.getElementById("transactionChart");
    const chartImage = await html2canvas(chartCanvas);
    const chartData = chartImage.toDataURL("image/png");
    pdf.addImage(chartData, "PNG", 40, 100, 520, 300);

    // Add summary data
    pdf.setFontSize(14);
    pdf.text("Summary Insights:", 40, 420);
    pdf.setFontSize(12);
    pdf.text("• Transactions Today: " + window.totalToday, 60, 440);
    pdf.text("• This Month: " + window.totalMonth, 60, 460);
    pdf.text("• This Year: " + window.totalYear, 60, 480);
    pdf.text("• Successful Transactions: " + window.successCount, 60, 500);
    pdf.text("• Failed Transactions: " + window.failedCount, 60, 520);

    pdf.save("Telemedicine_Dashboard_Report.pdf");
});
