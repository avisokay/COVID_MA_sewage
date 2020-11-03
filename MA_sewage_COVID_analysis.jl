using DataFrames, Plots, CSV, PyPlot, Statistics, StatsBase, Plotly

# import data
cases_by_date = CSV.read("C:\\Users\\Adam\\Desktop\\Code Projects\\GitHub\\COVID\\COVID_mass_sewage\\CasesByDate.csv")
sewage_by_date = CSV.read("C:\\Users\\Adam\\Desktop\\Code Projects\\GitHub\\COVID\\COVID_mass_sewage\\mass_sewage_data.csv")

# rename column headers
header = [x for x in sewage_by_date[2, :]]
header[1] = "Date"
header[2] = "copies_mL"
header[3] = "copies_mL"
rename!(sewage_by_date, header, makeunique = true)
sewage_by_date = sewage_by_date[3:end, :]
rename!(cases_by_date, ["Date", "Positive_Total", "Positive_New"])

# merge on date to combine dataframes
df = innerjoin(cases_by_date, sewage_by_date, on = :Date)
showall(head(df))

# replace missing with 0
replace!(df.copies_mL, missing => "0");
replace!(df.copies_mL_1, missing => "0");
replace!(df.avg, missing => "0");
replace!(df.avg_1, missing => "0");

# convert type from String to Int64
df.copies_mL = [parse(Int, x) for x in df.copies_mL];
df.copies_mL_1 = [parse(Int, x) for x in df.copies_mL_1];
df.avg = [parse(Int, x) for x in df.avg];
df.avg_1 = [parse(Int, x) for x in df.avg_1];

#create new variable for total daily copies/mL
df.daily_copies_mL = df.copies_mL + df.copies_mL_1

# graph daily positive new cases against daily copies/mL
using Plots
gr()
scatter(df.Date, df.Positive_New, xlabel = "Date", ylabel = "Daily Cases", xticks = 5, label = "Daily MA COVID-19 Cases", color = "blue", legend=:top)
scatter!(df.daily_copies_mL, ylabel = "Daily Copies/mL", label = "Daily MA Copies/mL", color = "red", ymirror=true, inset=(1,bbox(0,0,1,1)), bg_inside=RGBA(0,0,0,0), subplot=2, legend=:best)

# correlation
cor(df.Positive_New, df.daily_copies_mL)
