from flask import Flask, render_template
import psutil
import pandas as pd
from sklearn.ensemble import IsolationForest

app = Flask(__name__)

data = []
model = IsolationForest(contamination=0.1)

@app.route('/')
def dashboard():
    global data, model

    cpu = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory().percent
    disk = psutil.disk_usage('/').percent

    data.append([cpu, memory, disk])

    if len(data) > 50:
        data.pop(0)

    df = pd.DataFrame(data, columns=["cpu", "memory", "disk"])

    if len(df) > 10:
        model.fit(df)
        pred = model.predict(df.iloc[[-1]])
        anomaly = "🚨 Anomaly Detected!" if pred[0] == -1 else "✅ Normal"
    else:
        anomaly = "Collecting data..."

    return render_template(
        "index.html",
        cpu=cpu,
        memory=memory,
        disk=disk,
        anomaly=anomaly
    )

if __name__ == '__main__':
    app.run(debug=True)
