CASE #state_FB702 OF
        0:
            //Waiting for HMI button for MFC activation to be turned ON
            IF #IX_HMI_Button_ActivateMFC THEN
                //Reset [QB_MFC_Control_Mode], 3 to Stop, 0 to START
                #Outputs_MFC.QB_MFC_Control_Mode := 3;
                 
                //Reset [QB_MFC_Counter_Mode] = 0; 0 to Reset, 2 to count UP
                #Outputs_MFC.QB_MFC_Counter_Mode := 0;
                 
                //Reset;3 to RESET &amp; 0 to START
                #Outputs_MFC.QB_MFC_Reset := 3;
                 
                #ton_1(IN := NOT #ton_1.Q,
                       PT := t#2s);
                IF #ton_1.Q AND #Interlock_AllowMFC THEN
                    #state_FB702 := 20;
                    //#ton_1(IN := FALSE,PT := t#0s);
                END_IF;
            END_IF;
             
        20: //Here the Mass Flow starts
            //Enter a value for [QW_MFC_SP_Integer],Range = 0-32000, where 0 = No flow &amp; 32000 = Maximum flow OF MFC
            #Outputs_MFC.QW_MFC_SP_Integer := #IW_HMI_Recipe_FlowRate;
             
            //Enter a value for [QD_MFC_Counter_Limit] (Gas Volume)
            #Outputs_MFC.QD_MFC_Counter_Limit := #IW_HMI_Recipe_Volume;
             
            //Reset;3 to RESET &amp; 0 to START
            #Outputs_MFC.QB_MFC_Reset := 0;
             
            //Set [QB_MFC_Control_Mode], 0 TO Start
            #Outputs_MFC.QB_MFC_Control_Mode := 0;
             
            //Set [QB_MFC_Counter_Mode] = 2; 2 TO count UP TO limit
            #Outputs_MFC.QB_MFC_Counter_Mode := 2;
             
            #state_FB702 := 30;
             
        30: //Mass Flow stops when Counter has reached its limit (desired volume) or Interlock condition becomes False 
            IF #Inputs_MFC.ID_MFC_Count_Value>=#Inputs_MFC.ID_MFC_Counter_Limit THEN
                //Reset [QB_MFC_Control_Mode_O2], 3 TO Stop
                #Outputs_MFC.QB_MFC_Control_Mode := 3;
                //state change
                #state_FB702 := 40;
            END_IF;
             
            IF #Interlock_AllowMFC = FALSE OR MFC_Alarm <>0 THEN
                //Reset HMI button
                #IX_HMI_Button_ActivateMFC := False;
                //Reset [QB_MFC_Control_Mode_O2], 3 TO Stop
                #Outputs_MFC.QB_MFC_Control_Mode := 3;
                //state change
                #state_FB702 := 40;
            END_IF;
             
        40: //Waiting for HMI button for MFC activation to be turned OFF
                //User must de-activate supply button once from HMI to be able to Start another cycle
            IF  #IX_HMI_Button_ActivateMFC= FALSE THEN
                //Reset [QB_MFC_Counter_Mode] = 0; 0 TO Reset
                #Outputs_MFC.QB_MFC_Counter_Mode := 0;
                 
                //Reset all parameters; 3 to Reset
                #Outputs_MFC.QB_MFC_Reset := 3;
                 
                //state change
                #state_FB702 := 0;
            END_IF;
             
        99://Error state
            ;           
    END_CASE;