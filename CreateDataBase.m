%shipping noise
if 0
    T = readtable('Results.xlsx', 'Sheet', 'allcodas');
    T2 = readtable('Results.xlsx', 'Sheet', 'codaswithouturn');
    FileNameVec = T.REC;
    URN = T.URN;
    Focal = T.Focal;
    codaNUM1 = T.codaNUM2018;
    codaNUM2 = T2.codaNUM2018;

    ClickStruct = {};
    ClickNum = 0;
    ClickNumWithSNR = 0;
    for FileInd = 1: length(FileNameVec)
        CurrentU = URN(FileInd);
        CurrentFocal = Focal(FileInd);
        %use only focal whale
        if ((CurrentU == 0) || (CurrentU == 1)) && (CurrentFocal == 1)
            ClickNum = ClickNum + 1;
            ClickStruct(ClickNum).URN = CurrentU;
            ClickStruct(ClickNum).nClicks = T.nClicks(FileInd);
            ClickStruct(ClickNum).Duration = T.Duration(FileInd);
            ClickStruct(ClickNum).ICI1 = T.ICI1(FileInd);
            ClickStruct(ClickNum).ICI2 = T.ICI2(FileInd);
            ClickStruct(ClickNum).ICI3 = T.ICI3(FileInd);
            ClickStruct(ClickNum).ICI4 = T.ICI4(FileInd);
            ClickStruct(ClickNum).Name = T.Name(FileInd);
            ClickStruct(ClickNum).IPI1 = T.IPI1(FileInd);
            ClickStruct(ClickNum).IPI2 = T.IPI2(FileInd);
            ClickStruct(ClickNum).IPI3 = T.IPI3(FileInd);
            ClickStruct(ClickNum).IPI4 = T.IPI4(FileInd);

            %find vessel in AIS
            CurrentAIS = 0;
            CurrentNum1 = codaNUM1(FileInd);
            for FileInd2 = 1: length(codaNUM2)
                if CurrentNum1 == codaNUM2(FileInd2)
                    ThisAIS = T2.AIS_Data(FileInd2);
                    if ThisAIS == 1
                        CurrentAIS = 1;
                    end
                    break;
                end
            end
            ClickStruct(ClickNum).AIS = CurrentAIS;

            %find SNR
            CurrentFileName = FileNameVec(FileInd);
            CurrentFileName = CurrentFileName{:};
            loc = strfind(CurrentFileName, '_');
            if any(loc)
                File2Check = CurrentFileName(1:loc-1);
            else
                File2Check = CurrentFileName(1:end-2);
            end
            [CurrentSNR, CurrentRL] = GetSNR(File2Check, T.TsTo(FileInd), T.Duration(FileInd));
            ClickStruct(ClickNum).SNR = CurrentSNR;
            ClickStruct(ClickNum).RL = CurrentRL;
            if CurrentSNR < 999
                ClickNumWithSNR = ClickNumWithSNR + 1;
            end
        end
    end
    %save('ShippingClickStract');
else
    load('ShippingClickStract');
end

if 0
    %% correct for Name
    T = readtable('Results.xlsx', 'Sheet', 'allcodas');
    FileNameVec = T.REC;
    URN = T.URN;
    Focal = T.Focal;

    ClickNum = 0;
    for FileInd = 1: length(FileNameVec)
        CurrentU = URN(FileInd);
        CurrentFocal = Focal(FileInd);
        %use only focal whale
        if ((CurrentU == 0) || (CurrentU == 1)) && (CurrentFocal == 1)
            ClickNum = ClickNum + 1;
            CurrentName = readcell('Results.xlsx', 'Range', ['BA', num2str(FileInd+1),':BA',num2str(FileInd+1)]);
            ClickStruct(ClickNum).Name = CurrentName{:};
        end
    end
end

%% make databases
nClickVecURN = [];
nClickVecNoURN = [];
for ind = 1: length(ClickStruct)
    URN = ClickStruct(ind).URN;
    AIS = ClickStruct(ind).AIS;
    if URN == 1
        nClickVecURN = [nClickVecURN, ClickStruct(ind).nClicks];
    elseif URN == 0 && AIS == 0
        nClickVecNoURN = [nClickVecNoURN, ClickStruct(ind).nClicks];
    end
end
save('nClickRange', 'nClickVecURN', 'nClickVecNoURN');

DurationVecURN = [];
DurationVecNoURN = [];
for ind = 1: length(ClickStruct)
    URN = ClickStruct(ind).URN;
    AIS = ClickStruct(ind).AIS;
    if URN == 1
        DurationVecURN = [DurationVecURN, ClickStruct(ind).Duration];
    elseif URN == 0 && AIS == 0
        DurationVecNoURN = [DurationVecNoURN, ClickStruct(ind).Duration];
    end
end
save('DurationRange', 'DurationVecURN', 'DurationVecNoURN');

ICIVecURN = [];
ICIVecNoURN = [];
for ind = 1: length(ClickStruct)
    URN = ClickStruct(ind).URN;
    AIS = ClickStruct(ind).AIS;
    if URN == 1
        ICIVecURN = [ICIVecURN, ClickStruct(ind).ICI1, ClickStruct(ind).ICI2, ClickStruct(ind).ICI3, ClickStruct(ind).ICI4];
    elseif URN == 0 && AIS == 0
        ICIVecNoURN = [ICIVecNoURN, ClickStruct(ind).ICI1, ClickStruct(ind).ICI2, ClickStruct(ind).ICI3, ClickStruct(ind).ICI4];
    end
end
save('ICIRange', 'ICIVecURN', 'ICIVecNoURN');


ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    URN = ClickStruct(ind).URN;
    if URN == 1
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    else
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
% URN = ClickStruct.URN;
% pos1 = find(URN == 1);
% ClickVessel= ClickStruct(pos1);
% pos2 = find(URN == 0);
% ClickNoVessel = ClickStruct(pos2);
save('ShippingCodaData_Audio', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    AIS = ClickStruct(ind).AIS;
    URN = ClickStruct(ind).URN;
    if URN == 1 || AIS == 1
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif URN == 0 && AIS == 0
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
% AIS = ClickStruct.AIS;
% pos1 = find(URN == 1 | AIS == 1);
% ClickVessel = ClickStruct(pos1);
% pos2 = find(URN == 0 & AIS == 0);
% ClickNoVessel = ClickStruct(pos2);
save('ShippingCodaData_Audio_or_AIS', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    AIS = ClickStruct(ind).AIS;
    URN = ClickStruct(ind).URN;
    if URN == 1
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif URN == 0 && AIS == 0
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
% AIS = ClickStruct.AIS;
% pos1 = find(URN == 1);
% ClickVessel = ClickStruct(pos1);
% pos2 = find(URN == 0 & AIS == 0);
% ClickNoVessel = ClickStruct(pos2);
save('ShippingCodaData_Audio_and_AIS', 'ClickVessel', 'ClickNoVessel');


%% filter by SNR
ClickVessel = {};
ClickNoVessel = {};
SNRVec = [];
for ind = 1: length(ClickStruct)
    SNR = ClickStruct(ind).SNR;
    URN = ClickStruct(ind).URN;
    if URN == 1
       SNRVec = [SNRVec, SNR];
    end
    if (URN == 1) && (SNR < 5) && (SNR < 999)
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif URN == 0 
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
% SNR = ClickStruct.SNR;
% loc = find((SNR > 5) & (SNR < 999));
% URN = ClickStruct(loc).URN;
% pos1 = find(URN == 1);
% ClickVessel= ClickStruct(loc(pos1));
% pos2 = find(URN == 0);
% ClickNoVessel = ClickStruct(loc(pos2));
save('SNRRange', 'SNRVec');
save('ShippingCodaData_SNR5', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    SNR = ClickStruct(ind).SNR;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (SNR < 10) && (SNR < 999)
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif URN == 0 
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
% SNR = ClickStruct.SNR;
% loc = find((SNR > 10) & (SNR < 999));
% URN = ClickStruct(loc).URN;
% pos1 = find(URN == 1);
% ClickVessel= ClickStruct(loc(pos1));
% pos2 = find(URN == 0);
% ClickNoVessel = ClickStruct(loc(pos2));
save('ShippingCodaData_SNR10', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    SNR = ClickStruct(ind).SNR;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (SNR < 999)
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif URN == 0 
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
% SNR = ClickStruct.SNR;
% loc = find((SNR > 20) & (SNR < 999));
% URN = ClickStruct(loc).URN;
% pos1 = find(URN == 1);
% ClickVessel= ClickStruct(loc(pos1));
% pos2 = find(URN == 0);
% ClickNoVessel = ClickStruct(loc(pos2));
save('ShippingCodaData_SNRAll', 'ClickVessel', 'ClickNoVessel');

%% divide by whale name
ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'ATWOOD'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'ATWOOD'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
% loc = contains(ClickStruct.Name, 'ATWOOD');
% URN = ClickStruct(loc).URN;
% pos1 = find(URN == 1);
% ClickVessel= ClickStruct(loc(pos1));
% pos2 = find(URN == 0);
% ClickNoVessel = ClickStruct(loc(pos2));
save('ShippingCodaData_ATWOOD', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'FORK'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'FORK'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_FORK', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'NALGENE'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'NALGENE'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_NALGENE', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'TWEAK'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'TWEAK'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_TWEAK', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'PINCHY'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'PINCHY'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_PINCHY', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'TBB'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'TBB'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_TBB', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'SAM'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'SAM'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_SAM', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'LAIUS'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'LAIUS'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_LAIUS', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'SOPH'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'SOPH'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_SOPH', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'UNID'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'UNID'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_UNID', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'FRUIT'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'FRUIT'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_FRUIT', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'SOURSOP'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'SOURSOP'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_SOURSOP', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'JOCASTA'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'JOCASTA'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_JOCASTA', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'LADYO'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'LADYO'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_LADYO', 'ClickVessel', 'ClickNoVessel');

ClickVessel = {};
ClickNoVessel = {};
for ind = 1: length(ClickStruct)
    Name = ClickStruct(ind).Name;
    URN = ClickStruct(ind).URN;
    if (URN == 1) && (contains(Name, 'SALLY'))
        ClickVessel = [ClickVessel, ClickStruct(ind)];
    elseif (URN == 0) && (contains(Name, 'SALLY'))
        ClickNoVessel = [ClickNoVessel, ClickStruct(ind)];
    end
end
save('ShippingCodaData_SALLY', 'ClickVessel', 'ClickNoVessel');

