# lua-performance-demo
A demo using WRK and flame graph to locate OpenResty performance issues

## 🏆 黄金价格监控系统

新增的黄金价格实时监控功能，支持多种时间维度的价格展示。

### 快速启动

```bash
# 启动黄金价格监控系统
./start_gold_price.sh
```

### 访问地址

- **主页面**: http://localhost:8080/gold
- **API接口**: http://localhost:8080/gold-price

### 功能特性

- 📊 **多时间维度**: 支持近1个月、近1天、近1小时、实时价格展示
- 🔄 **自动刷新**: 实时价格每30秒刷新，历史数据每1分钟刷新
- 📈 **图表展示**: 直观的价格走势图表
- 📋 **数据表格**: 详细的价格数据表格
- 📱 **响应式设计**: 支持移动端访问

### API接口说明

#### 获取价格数据
```
GET /gold-price?period={period}
```

参数说明：
- `period`: 时间维度
  - `month`: 近1个月（按天）
  - `day`: 近1天（按小时）
  - `hour`: 近1小时（按分钟）
  - `current`: 实时价格

#### 响应格式
```json
{
  "data": [
    {
      "date": "2024-01-01",
      "price": 1950.50,
      "change": 2.50
    }
  ],
  "type": "daily"
}
```

## 性能测试

# using WRK for benchmark
```bash
wrk -c100 -t10 -d20s http://127.0.0.1:8080
```

# using systemtap and stapxx to get flamegraph
```bash
export PATH=/media/psf/Home/work/stapxx:/media/psf/Home/work/FlameGraph:/media/psf/Home/work/openresty-systemtap-toolkit:$PATH

./samples/lj-lua-stacks.sxx --arg time=5  --skip-badvars -x 4959 > a.bt

stackcollapse-stap.pl a.bt > a.cbt

flamegraph.pl --encoding="ISO-8859-1" \
              --title="Lua-land on-CPU flamegraph" \
              a.cbt > a.svg
```
