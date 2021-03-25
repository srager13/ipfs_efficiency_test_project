import argparse
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser()
parser.add_argument("filename", help="Name of the log file with data from latency experiments.")
parser.add_argument("output_dir", help="Directory to which the resulting plot should be saved.")
args = parser.parse_args()

print(f"Reading data from {args.filename}")

# read in data
data = pd.read_csv(args.filename)

# merge num providers and fetchers into single column
data["Num Providers, Num Fetchers"] = data["Number_Providers"].astype(str) + " Providers, " + \
                                      data["Number_Fetchers"].astype(str) + " Fetchers"

# average the download times for each combination of (num providers, num fetchers, filesize)
avg_download_time = data.groupby(["Num Providers, Num Fetchers", "Filesize"]).agg({"Download_Time": ["mean"]})
avg_download_time.columns = ["Avg. Download Time"]
avg_download_time = avg_download_time.reset_index()

# scale file sizes to MB
avg_download_time["Filesize"] = avg_download_time["Filesize"]*0.000001

sns.lineplot(data=avg_download_time, x="Filesize", y="Avg. Download Time", hue="Num Providers, Num Fetchers",
             style="Num Providers, Num Fetchers", markers=True)
plt.title("IPFS Download Time vs. Filesize")
plt.xlabel("Filesize (MB)")
plt.ylabel("Avg. Download Time (Seconds)")
plt.savefig(f"{args.output_dir}/avg_download_time_vs_filesize.png")
