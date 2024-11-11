import pandas as pd
import numpy as np
from sklearn.metrics import r2_score, mean_squared_error
import matplotlib.pyplot as plt

def createDF(file, column):
    return pd.read_csv(file, header=None, names=column)

df = createDF("x_train.txt", ["y_test"])
y_pred = [value * 0.98 for value in df['y_test']]
y_pred = pd.DataFrame(y_pred,columns=['pred'])

r2 = r2_score(df['y_test'], y_pred['pred'])
mse = mean_squared_error(df['y_test'], y_pred['pred'])
K = 2
W = 2
H = 3

date = range(1, len(df) + 1)

plt.figure(figsize=(10, 6))
plt.plot(date, df['y_test'], label="Valores Reais", marker='o')
plt.plot(date, y_pred['pred'], label="Valores Previstos", marker='x', linestyle="--")
plt.xlabel("Dia de Previsão")
plt.ylabel("Valor da Ação")
plt.title("Comparação entre Valores Reais e Preditos")

plt.text(0.05, 0.95, f"R²: {r2:.4f}\nMSE: {mse:.2f}\nK: {K}\nW: {W}\nH: {H}", 
         transform=plt.gca().transAxes, fontsize=12, 
         verticalalignment='top', bbox=dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="lightgray"))

plt.legend()
plt.show()

residuals = df['y_test'] - y_pred['pred']
plt.scatter(y_pred, residuals)
plt.axhline(0, color='black', linestyle='--')
plt.xlabel("Valores Preditos")
plt.ylabel("Resíduos")
plt.title("Resíduos vs Valores Preditos")
plt.show()