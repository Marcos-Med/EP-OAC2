import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

df1 = pd.read_csv("dados_cpu.txt", header=None, names=['data'])
df2 = pd.read_csv("dados_threads.txt", header=None, names=['data'])

print(df1['data'])
print(df2['data'])

values = np.array([10, 30, 50, 100, 1000, 100000, 1000000])
plt.figure(figsize=(10,6))
plt.plot(values, df1['data'], label='Sequencial', marker='o')
plt.plot(values, df2['data'], label='OpenMP', marker='x', linestyle='--')
plt.xlabel("Quantidade de Dados")
plt.ylabel("Tempo de execução (Segundos)")
plt.title("Tempo de execução KNN")
plt.legend()
plt.show()
