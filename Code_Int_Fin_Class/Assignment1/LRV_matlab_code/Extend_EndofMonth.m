function Data_Extended = Extend_EndofMonth(Data)

N         = size(Data,1);
dates = datetime(Data(:, 1),'ConvertFrom','datenum');
DaysToEoM = datenum(year(dates(end)),month(dates(end)),eomday(year(dates(end)),month(dates(end))))-datenum(dates(end));

for t = 1:DaysToEoM+2
    for n=1:size(Data,3)
        Data(N+t,2:end,n) = Data(N,2:end,n);
        Data(N+t,1,n)     = Data(N,1,n)+t;
    end
end

Data_Extended = Data;