function result=OHCO(PowerTend,MaxEnergy,HeatCost,PowerNeed,SOE0,T0)
    if SOE0<0||SOE0>1
        fprintf("battery SOE0 should be bewteen 0~1.\n");
        result.state=0;
        return;
    end
    if PowerNeed<0
        fprintf("battery PowerNeed should be larger than 0.\n");
        result.state=0;
        return;
    end
    SumHeatCost = @(Tend)abs(integral(@(x)HeatCost(x,T0),Tend-T0,0));
    SumEnergy = @(Tend)SOE0.*MaxEnergy(Tend);
    AvailableEnergy = @(Tend)-(SumEnergy(Tend)-SumHeatCost(Tend));
    ObjFun1 = @(Tend)(PowerTend(Tend,SOE0.*100)-PowerNeed);

    if PowerNeed==0
        bestTend_power=T0;
    else
        bestTend_power = fzero(ObjFun1,0);
    end
    i=1;
    while i==1
        if T0>=bestTend_power||55<bestTend_power
            SOEnew1 = SOE0;
            bestTend_power = T0;
        else
            SOEnew1 = -AvailableEnergy(bestTend_power)/MaxEnergy(bestTend_power);
        end

        if SOEnew1 <= 0
            fprintf("Battery cold start failed because of low SOE.\n");
            result.state=0;
            break;
        else
            [bestTend_energy, LargestEnergy] = fminbnd(AvailableEnergy,bestTend_power,25);
            SOEend = -LargestEnergy/MaxEnergy(bestTend_energy);
            Powerend = PowerTend(bestTend_energy,SOEend*100);
            Energyend=-LargestEnergy;
            HeatEnergy=SumHeatCost(bestTend_energy);
 
            if Powerend < PowerNeed
                fprintf("battery cold start failed because of power need cant be satisfied with max energy.\n");
                fprintf("battery cold start at new SOE=%f (%%).\n", SOEnew1.*100);
                fprintf("battery cold start at new temperature=%f (degC).\n", bestTend_power);
                ObjFun1 = @(Tend)(PowerTend(Tend,SOEnew1.*100)-PowerNeed);
                bestTend_power = fzero(ObjFun1,0);
                if bestTend_power < T0
                    fprintf("Battery cold start failed because of low SOE.\n");
                    result.state=0;
                    break;
                else
                    SOEnew1 = -AvailableEnergy(bestTend_power)/MaxEnergy(bestTend_power);
                end

                i=1;
            else
                i=0;
                if bestTend_power==bestTend_energy
                
                    fprintf("battery cold start success meeting powerdemand but not maximum recovered energy.\n");
                    fprintf("Cold start Temperature=%f (degC) \n",T0);
                    fprintf("End Temperature=%f (degC) \n",bestTend_energy);                    
                    fprintf("Cold start Energy=%f (Wh) \n",SumEnergy(T0));
                    fprintf("End Energy=%f (Wh) \n",Energyend);                    
                    fprintf("Cold start SOE=%f (%%) \n",SOE0*100);
                    fprintf("End SOE=%f (%%) \n",SOEend*100);                    
                    fprintf("HeatEnergy=%f (Wh) \n",HeatEnergy);                    
                    fprintf("Power Need = %f (W) \n",PowerNeed);
                    fprintf("End Power=%f (W) \n",Powerend);

                    result.state=1;
                    result.HeatEnergy=HeatEnergy;
                    result.SOEend=SOEend;
                    result.Energyend=Energyend;
                    result.Tend=bestTend_energy;
                    result.Powerend=Powerend;
                elseif bestTend_power<bestTend_energy
                    fprintf("battery cold start success meeting powerdemand and maximum recovered energy.\n");
                    fprintf("Cold start Temperature=%f (degC) \n",T0);
                    fprintf("End Temperature=%f (degC) \n",bestTend_energy);
                    fprintf("Cold start Energy=%f (Wh) \n",SumEnergy(T0));
                    fprintf("End Energy=%f (Wh) \n",Energyend);
                    fprintf("Cold start SOE=%f (%%) \n",SOE0*100);
                    fprintf("End SOE=%f (%%) \n",SOEend*100);    
                    fprintf("HeatEnergy=%f (Wh) \n",HeatEnergy);
                    fprintf("Power Need = %f (W) \n",PowerNeed);
                    fprintf("End Power=%f (W) \n",Powerend);
                    result.state=2;
                    result.HeatEnergy=HeatEnergy;
                    result.SOEend=SOEend;
                    result.Energyend=Energyend;
                    result.Tend=bestTend_energy;
                    result.Powerend=Powerend;
                else
                    fprintf("Error!\n");
                end
            end

        end
    end

end
