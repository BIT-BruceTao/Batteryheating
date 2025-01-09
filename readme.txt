OHCO is the function to achieve battery optimal heating cut-off temperature. 

result=OHCO(PowerTend,MaxEnergy,HeatCost,PowerNeed,SOE0,T0)

PowerTend is the function handle of battery power which is vary with SOE and battery temperature. And it should be obtained by experiement. PowerTend(SOE, T)
MaxEnergy is the function handle of battery max energy which is vary with battery temperature. It should be obtained by experiement. MaxEnergy(T)
HeatCost is the function of heating system energy consumption's derivatives which is vary with T0 and battery heating temperature rise. It should be obtained by experiement. Heatcost(T0,deltaT)

result is a structure about heating result.
result.state is heating state, 0 means heating failure (battery start state is in dead zone), 1 means heating sucessful with power demand but not max available energy, 2 means heating  sucessful with both power demand and max available energy.
result.HeatEnergy is heating energy consumption during process.
result.SOEend is battery SOE when heating stop.
result.Energyend is battery available energy when heating stop.
result.Tend is optimal  heating cut-off temperature.
result.Powerend battery output power when heating stop.

4 .sfit is obtained by matlab curve fitting tool.