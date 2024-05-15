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
# print(f"Intended working directory: {os.getcwd()}")

chinese_font = FontProperties(fname='./Code/Songti.ttc')

########### World PV New Installed Capacity and Forecast.png

data = pd.read_csv('./Data/1_全球装机预测.csv')

# 提取类别和各区域数据
years = data['年份']
china = data['中国']
world = data['世界']
non_china = world - china
regions = data.columns[1:]

# 设置柱状图的宽度
bar_width = 0.4

# 绘制柱状图
fig, ax = plt.subplots(figsize=(7, 4))

bar1 = ax.bar(years, china, bar_width, label='中国', color='green')
bar2 = ax.bar(years, world - china, bar_width, bottom=china, label='全球（除中国外）', color='lightgreen')

# 在每个柱子上显示总高度
for i in range(len(years)):
    total_height = china[i] + non_china[i]
    ax.text(years[i], total_height + 5, f'{total_height:.1f}', ha='center', fontproperties=chinese_font)


# 设置标题和标签
# ax.set_title('全球光伏新增装机量 (单位: GW)', fontproperties=chinese_font)
ax.set_xlabel('年份', fontproperties=chinese_font)
ax.set_ylabel('装机量 (GW)', fontproperties=chinese_font)
ax.legend(prop=chinese_font)
plt.xticks(ticks=years, labels=years, fontproperties=chinese_font)

path = "./Figure/World PV New Installed Capacity and Forecast.png"
plt.savefig(path, dpi=300, bbox_inches='tight')
plt.close()


####################### LCOE
### 数据来源：Lazard（./Raw Material/lazards-lcoeplus-april-2023.pdf）

# 数据
categories = ['Solar PV—Rooftop Residential', 'Solar PV—Community C&I', 
              'Solar PV—Utility-Scale', 'Solar PV + Storage—Utility-Scale', 
              'Geothermal', 'Wind—Onshore', 'Wind+Storage—Onshore', 'Wind—Offshore',
              'Gas Peaking', 'Nuclear', 'Coal', 'Gas Combined Cycle']
min_costs = [117, 49, 24, 46, 61, 24, 42, 72, 115, 141, 68, 39]
max_costs = [282, 185, 96, 102, 102, 75, 114, 140, 221, 221, 166, 101]


N = len(categories)
fig, ax = plt.subplots(figsize=(10, 5))

for i, (min_cost, max_cost) in enumerate(zip(min_costs, max_costs)):
    ax.barh(categories[i], max_cost - min_cost, left=min_cost, color='lightgreen', edgecolor='black')
    ax.text(max_cost + 3, i, f'${max_cost}', va='center', ha='left', color='black')
    ax.text(min_cost - 3, i, f'${min_cost}', va='center', ha='right', color='black')

ax.set_xlabel('Leveled Cost of Energy ($/MWh)')

# 设置图形的标题
# ax.set_title('Levelized Cost of Energy Comparison—Unsubsidized Analysis')

ax.grid(False)
ax.set_xlim(0, 300)
ax.invert_yaxis()

plt.tight_layout()
path = "./Figure/LCOE.png"
plt.savefig(path, dpi=300, bbox_inches='tight')
plt.close()