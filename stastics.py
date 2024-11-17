import pandas as pd
from sklearn.metrics import r2_score, mean_squared_error
import matplotlib.pyplot as plt

def createDF(file, column):
    return pd.read_csv(file, header=None, names=column, encoding="ascii")

pred = createDF("y_pred.txt", ["y_pred"])
test= createDF("y_test.txt", ["y_test"])

print(test.head())

r2 = r2_score(test['y_test'], pred['y_pred'])
mse = mean_squared_error(test['y_test'], pred['y_pred'])
K = 6
W = 2
H = 1

date = range(1, len(pred) + 1)

plt.figure(figsize=(10, 6))
plt.plot(date, test['y_test'], label="Valores Reais", marker='o')
plt.plot(date, pred['y_pred'], label="Valores Previstos", marker='x', linestyle="--")
plt.xlabel("Dia de Previsão")
plt.ylabel("Valor da Ação")
plt.title("Comparação entre Valores Reais e Preditos")

plt.text(0.05, 0.95, f"R²: {r2:.4f}\nMSE: {mse:.2f}\nK: {K}\nW: {W}\nH: {H}", 
         transform=plt.gca().transAxes, fontsize=12, 
         verticalalignment='top', bbox=dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="lightgray"))

plt.legend()
plt.show()
