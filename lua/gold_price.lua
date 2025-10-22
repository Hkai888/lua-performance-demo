local json = require "cjson"
local http = require "resty.http"
local math_random = math.random

local _M = {}

-- 模拟黄金价格数据生成器
local function generate_gold_price_data()
    local data = {}
    local base_price = 1950.0 -- 基础价格（美元/盎司）
    local current_time = os.time()
    
    -- 生成近1个月的数据（按天）
    for i = 30, 0, -1 do
        local day_time = current_time - (i * 24 * 3600)
        local day_data = {
            date = os.date("%Y-%m-%d", day_time),
            price = base_price + math_random() * 100 - 50, -- 价格波动 ±50
            change = math_random() * 20 - 10 -- 涨跌幅 ±10
        }
        table.insert(data, day_data)
    end
    
    return data
end

-- 生成小时数据
local function generate_hourly_data()
    local data = {}
    local base_price = 1950.0
    local current_time = os.time()
    
    -- 生成最近24小时的数据
    for i = 23, 0, -1 do
        local hour_time = current_time - (i * 3600)
        local hour_data = {
            time = os.date("%H:%M", hour_time),
            price = base_price + math_random() * 20 - 10,
            change = math_random() * 5 - 2.5
        }
        table.insert(data, hour_data)
    end
    
    return data
end

-- 生成分钟数据
local function generate_minute_data()
    local data = {}
    local base_price = 1950.0
    local current_time = os.time()
    
    -- 生成最近60分钟的数据
    for i = 59, 0, -1 do
        local minute_time = current_time - (i * 60)
        local minute_data = {
            time = os.date("%H:%M", minute_time),
            price = base_price + math_random() * 5 - 2.5,
            change = math_random() * 2 - 1
        }
        table.insert(data, minute_data)
    end
    
    return data
end

-- 获取实时价格
local function get_current_price()
    local base_price = 1950.0
    return {
        price = base_price + math_random() * 10 - 5,
        change = math_random() * 3 - 1.5,
        timestamp = os.time()
    }
end

-- 处理API请求
function _M.handle_request()
    local args = ngx.req.get_uri_args()
    local period = args.period or "month"
    
    local response = {}
    
    if period == "month" then
        response.data = generate_gold_price_data()
        response.type = "daily"
    elseif period == "day" then
        response.data = generate_hourly_data()
        response.type = "hourly"
    elseif period == "hour" then
        response.data = generate_minute_data()
        response.type = "minute"
    elseif period == "current" then
        response.data = get_current_price()
        response.type = "current"
    else
        ngx.status = 400
        ngx.say(json.encode({error = "Invalid period parameter"}))
        return
    end
    
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say(json.encode(response))
end

-- 获取黄金价格页面
function _M.get_gold_price_page()
    local html = [[
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>黄金价格实时监控</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #ffd700 0%, #ffed4e 100%);
            padding: 30px;
            text-align: center;
            color: #333;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        
        .current-price {
            font-size: 3em;
            font-weight: bold;
            margin: 20px 0;
            color: #2c3e50;
        }
        
        .price-change {
            font-size: 1.2em;
            padding: 8px 16px;
            border-radius: 20px;
            display: inline-block;
        }
        
        .price-up {
            background: #e8f5e8;
            color: #27ae60;
        }
        
        .price-down {
            background: #ffeaea;
            color: #e74c3c;
        }
        
        .controls {
            padding: 20px;
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
        }
        
        .time-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .time-btn {
            padding: 12px 24px;
            border: none;
            border-radius: 25px;
            background: #6c757d;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
            font-weight: bold;
        }
        
        .time-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .time-btn.active {
            background: #007bff;
        }
        
        .chart-container {
            padding: 30px;
            height: 400px;
            position: relative;
        }
        
        .chart {
            width: 100%;
            height: 100%;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            background: #fafafa;
            position: relative;
            overflow: hidden;
        }
        
        .data-table {
            margin-top: 20px;
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e9ecef;
        }
        
        th {
            background: #f8f9fa;
            font-weight: bold;
            color: #495057;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .loading {
            text-align: center;
            padding: 50px;
            color: #6c757d;
            font-size: 1.2em;
        }
        
        .error {
            text-align: center;
            padding: 50px;
            color: #e74c3c;
            font-size: 1.2em;
        }
        
        @media (max-width: 768px) {
            .header h1 {
                font-size: 2em;
            }
            
            .current-price {
                font-size: 2em;
            }
            
            .time-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .time-btn {
                width: 200px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏆 黄金价格实时监控</h1>
            <div class="current-price" id="currentPrice">$1,950.00</div>
            <div class="price-change" id="priceChange">+2.50 (+0.13%)</div>
        </div>
        
        <div class="controls">
            <div class="time-buttons">
                <button class="time-btn active" data-period="month">近1个月</button>
                <button class="time-btn" data-period="day">近1天</button>
                <button class="time-btn" data-period="hour">近1小时</button>
                <button class="time-btn" data-period="current">实时价格</button>
            </div>
        </div>
        
        <div class="chart-container">
            <div class="chart" id="priceChart">
                <div class="loading">正在加载数据...</div>
            </div>
        </div>
        
        <div class="data-table" id="dataTable" style="display: none;">
            <table>
                <thead>
                    <tr>
                        <th>时间</th>
                        <th>价格 (USD/oz)</th>
                        <th>涨跌</th>
                        <th>涨跌幅</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                </tbody>
            </table>
        </div>
    </div>

    <script>
        let currentPeriod = 'month';
        let priceData = [];
        
        // 初始化页面
        document.addEventListener('DOMContentLoaded', function() {
            loadCurrentPrice();
            loadPriceData('month');
            
            // 设置定时刷新
            setInterval(loadCurrentPrice, 30000); // 30秒刷新一次实时价格
            setInterval(() => loadPriceData(currentPeriod), 60000); // 1分钟刷新一次数据
        });
        
        // 时间按钮事件
        document.querySelectorAll('.time-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.time-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                currentPeriod = this.dataset.period;
                loadPriceData(currentPeriod);
            });
        });
        
        // 加载实时价格
        async function loadCurrentPrice() {
            try {
                const response = await fetch('/gold-price?period=current');
                const data = await response.json();
                
                if (data.data) {
                    document.getElementById('currentPrice').textContent = '$' + data.data.price.toFixed(2);
                    
                    const changeElement = document.getElementById('priceChange');
                    const change = data.data.change;
                    const changePercent = ((change / (data.data.price - change)) * 100).toFixed(2);
                    
                    changeElement.textContent = (change >= 0 ? '+' : '') + change.toFixed(2) + 
                                             ' (' + (change >= 0 ? '+' : '') + changePercent + '%)';
                    changeElement.className = 'price-change ' + (change >= 0 ? 'price-up' : 'price-down');
                }
            } catch (error) {
                console.error('加载实时价格失败:', error);
            }
        }
        
        // 加载价格数据
        async function loadPriceData(period) {
            try {
                const response = await fetch('/gold-price?period=' + period);
                const data = await response.json();
                
                if (data.data) {
                    priceData = data.data;
                    renderChart();
                    renderTable();
                }
            } catch (error) {
                console.error('加载价格数据失败:', error);
                document.getElementById('priceChart').innerHTML = '<div class="error">数据加载失败</div>';
            }
        }
        
        // 渲染图表
        function renderChart() {
            const chartElement = document.getElementById('priceChart');
            
            if (currentPeriod === 'current') {
                chartElement.innerHTML = '<div style="text-align: center; padding: 50px; color: #6c757d;">实时价格模式 - 请查看上方实时价格显示</div>';
                document.getElementById('dataTable').style.display = 'none';
                return;
            }
            
            // 简单的SVG图表实现
            const width = chartElement.offsetWidth;
            const height = chartElement.offsetHeight;
            
            if (priceData.length === 0) {
                chartElement.innerHTML = '<div class="loading">暂无数据</div>';
                return;
            }
            
            const prices = priceData.map(item => item.price);
            const minPrice = Math.min(...prices);
            const maxPrice = Math.max(...prices);
            const priceRange = maxPrice - minPrice;
            
            const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
            svg.setAttribute('width', width);
            svg.setAttribute('height', height);
            
            // 绘制价格线
            const pathData = priceData.map((item, index) => {
                const x = (index / (priceData.length - 1)) * (width - 40) + 20;
                const y = height - 40 - ((item.price - minPrice) / priceRange) * (height - 80);
                return `${index === 0 ? 'M' : 'L'} ${x} ${y}`;
            }).join(' ');
            
            const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            path.setAttribute('d', pathData);
            path.setAttribute('stroke', '#007bff');
            path.setAttribute('stroke-width', '3');
            path.setAttribute('fill', 'none');
            
            svg.appendChild(path);
            
            // 绘制数据点
            priceData.forEach((item, index) => {
                const x = (index / (priceData.length - 1)) * (width - 40) + 20;
                const y = height - 40 - ((item.price - minPrice) / priceRange) * (height - 80);
                
                const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
                circle.setAttribute('cx', x);
                circle.setAttribute('cy', y);
                circle.setAttribute('r', '4');
                circle.setAttribute('fill', '#007bff');
                
                svg.appendChild(circle);
            });
            
            chartElement.innerHTML = '';
            chartElement.appendChild(svg);
            
            // 显示数据表格
            document.getElementById('dataTable').style.display = 'block';
        }
        
        // 渲染数据表格
        function renderTable() {
            const tbody = document.getElementById('tableBody');
            tbody.innerHTML = '';
            
            priceData.forEach(item => {
                const row = document.createElement('tr');
                
                const timeCell = document.createElement('td');
                timeCell.textContent = item.date || item.time || '实时';
                
                const priceCell = document.createElement('td');
                priceCell.textContent = '$' + item.price.toFixed(2);
                
                const changeCell = document.createElement('td');
                const change = item.change || 0;
                changeCell.textContent = (change >= 0 ? '+' : '') + change.toFixed(2);
                changeCell.style.color = change >= 0 ? '#27ae60' : '#e74c3c';
                
                const changePercentCell = document.createElement('td');
                const changePercent = ((change / (item.price - change)) * 100).toFixed(2);
                changePercentCell.textContent = (changePercent >= 0 ? '+' : '') + changePercent + '%';
                changePercentCell.style.color = change >= 0 ? '#27ae60' : '#e74c3c';
                
                row.appendChild(timeCell);
                row.appendChild(priceCell);
                row.appendChild(changeCell);
                row.appendChild(changePercentCell);
                
                tbody.appendChild(row);
            });
        }
    </script>
</body>
</html>
    ]]
    
    ngx.header.content_type = "text/html; charset=utf-8"
    ngx.say(html)
end

return _M
