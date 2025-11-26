// Function to fetch data from the server based on period
async function fetchChartData(period, dashboardType = 'ussd') {
    try {
        const response = await fetch('fetch_data.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                period: period,
                type: dashboardType
            })
        });

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error fetching data:', error);
        return null;
    }
}

// Function to update chart with new data
async function updateChartData(period, dashboardType = 'ussd') {
    if (!currentChart) return;

    const data = await fetchChartData(period, dashboardType);
    if (!data) return;

    currentPeriod = period;
    
    // Update chart data
    currentChart.data.labels = data.labels;
    currentChart.data.datasets[0].data = data.values;
    
    // Update chart title
    const titlePrefix = dashboardType === 'ussd' ? 'Transactions' : 'App Usage';
    currentChart.options.plugins.title.text = `${period.charAt(0).toUpperCase() + period.slice(1)}ly ${titlePrefix}`;
    
    // Refresh chart
    currentChart.update();

    // Update statistics if they exist
    if (data.stats) {
        updateStatistics(data.stats, dashboardType);
    }
}

// Function to update statistics cards
function updateStatistics(stats, dashboardType) {
    const todayElement = document.getElementById('today-count');
    const monthElement = document.getElementById('month-count');
    const yearElement = document.getElementById('year-count');

    if (dashboardType === 'ussd') {
        if (todayElement) todayElement.textContent = stats.today;
        if (monthElement) monthElement.textContent = stats.month;
        if (yearElement) yearElement.textContent = stats.year;
    } else {
        if (todayElement) todayElement.textContent = stats.activeToday;
        if (monthElement) monthElement.textContent = stats.activeMonth;
        if (yearElement) yearElement.textContent = stats.totalDownloads;
    }
}