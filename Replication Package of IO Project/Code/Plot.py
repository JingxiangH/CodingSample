import os
import platform
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.font_manager import FontProperties

# Set working directories
paths = {
    "Darwin": "/Users/huangjingxiang/Library/CloudStorage/Dropbox/大三下/Coding Sample/Replication Package of IO Project/",
    "Windows": "C:\\Users\\iamja\\Dropbox\\大三下\\Coding Sample\\Replication Package of IO Project\\"
}

new_path = paths.get(platform.system(), os.getcwd())
os.chdir(new_path)
print(f"Intended working directory: {os.getcwd()}")

chinese_font = FontProperties(fname='./Code/Songti.ttc')

########### China PV New Installed Capacity and Forecast.png

Data_Installed_Capacity = pd.read_csv('./Data/装机量.csv')
years = Data_Installed_Capacity["Year"]
conservative_scenario = Data_Installed_Capacity["Conservative_Scenario"]
optimistic_scenario = Data_Installed_Capacity["Optimistic_Scenario"]

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

path = "./Figure/China PV New Installed Capacity and Forecast.png"
plt.savefig(path, dpi=300)
plt.close()

########### World PV New Installed Capacity and Forecast.png

# 使用StringIO读取CSV数据
data = pd.read_csv('./Data/1_全球装机预测.csv')

# 提取类别和各区域数据
years = data['Year']
regions = data.columns[1:]

# 绘制图表
plt.figure(figsize=(8, 5))
for region in regions:
    plt.plot(years, data[region], label=region)

# plt.title('全球各国各地区的光伏新增装机量 (单位: GW)', fontproperties=chinese_font)
plt.xlabel('年份', fontproperties=chinese_font)
plt.ylabel('装机量（GW）', fontproperties=chinese_font)
plt.legend(prop=chinese_font, bbox_to_anchor=(1.05, 1), loc='upper left')
plt.grid(True)
plt.xticks(ticks=np.arange(years.min(), years.max()+1, 1), labels=np.arange(years.min(), years.max()+1, 1), fontproperties=chinese_font)  # 每年显示一次
plt.xlim(years.min(), years.max())

# 保存图表，增加DPI以提高清晰度
path = "./Figure/World PV New Installed Capacity and Forecast.png"
plt.savefig(path, dpi=300, bbox_inches='tight')
