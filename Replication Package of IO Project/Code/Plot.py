import matplotlib.pyplot as plt
import numpy as np
from matplotlib.font_manager import FontProperties

chinese_font = FontProperties(fname='./Songti.ttc')

########### China PV New Installed Capacity and Forecast.png

# 数据点
years = np.array([2011, 2012, 2013, 2014, 2015, 
                  2016, 2017, 2018, 2019, 2020, 
                  2021, 2022, 2023, 2024, 2025, 
                  2027, 2030])
conservative_scenario = np.array([1, 3, 10, 11, 17, 
                                  31, 52, 42, 30, 48,
                                  53, 88, 95, 95, 101, 
                                  108, 120])
optimistic_scenario = np.array([1, 3, 10, 11, 17, 
                                  31, 52, 42, 30, 48,
                                  53, 88, 120, 120, 125, 
                                  130, 140])

# 绘制图表
plt.figure(figsize=(6, 4))
plt.plot(years, conservative_scenario, label='保守情形', marker='o', color='orange')
plt.plot(years, optimistic_scenario, label='乐观情形', marker='o', color='red')
# plt.title('2011-2030年中国光伏新增装机量及预测（单位：GW）', fontproperties=chinese_font)
plt.xlabel('年份', fontproperties=chinese_font)
plt.ylabel('装机量（GW）', fontproperties=chinese_font)
plt.legend(prop=chinese_font)
plt.grid(True)
plt.xticks(ticks=np.arange(2011, 2031, 3), labels=np.arange(2011, 2031, 3))  # 每隔三年显示一次
plt.xlim(2011, 2030)

path = "./China PV New Installed Capacity and Forecast.png"
plt.savefig(path, dpi=300)
plt.close()