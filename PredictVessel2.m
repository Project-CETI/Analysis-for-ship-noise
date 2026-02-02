% Predict
PlotFlag = 0;
VALIDATION_SET_NUM = 4;
TrainSimNum = 1;
TestSimNum = 1;
KFold = 0.25;
TestPrecentage = 0.1;
%KernelChosen = 'polynomial'; %'linear' | 'gaussian' | 'rbf' | 'polynomial'
%KernelChosenVec = {'linear', 'gaussian' , 'rbf' , 'polynomial'};
%KernelNum = 4;
KernelChosenVec = {'rbf'};
KernelNum = 1;
NUM_FEATURES = 10;
FEATURES_TO_SELECT = 4; % Number of features to select
MinNumVesselSample = 50;
FeatureNum = 12;
DataSetNum = 21;

TestTPMat = zeros(DataSetNum, FeatureNum);
TestFNMat = zeros(DataSetNum, FeatureNum);
TestTNMat = zeros(DataSetNum, FeatureNum);
TestFPMat = zeros(DataSetNum, FeatureNum);
DidDataSet = zeros(1, DataSetNum);
for DataSetInd = 1: DataSetNum

    DataSetInd

    switch(DataSetInd)
        case(1)
            DataName = 'ShippingCodaData_Audio';
        case(2)
            DataName = 'ShippingCodaData_Audio_or_AIS';
        case(3)
            DataName = 'ShippingCodaData_Audio_and_AIS';
        case(4)
            DataName = 'ShippingCodaData_SNR5';
        case(5)
            DataName = 'ShippingCodaData_SNR10';
        case(6)
            DataName = 'ShippingCodaData_SNRAll';
        case(7)
            DataName = 'ShippingCodaData_ATWOOD';
        case(8)
            DataName = 'ShippingCodaData_FORK';
        case(9)
            DataName = 'ShippingCodaData_NALGENE';
        case(10)
            DataName = 'ShippingCodaData_TWEAK';
        case(11)
            DataName = 'ShippingCodaData_TBB';
        case(12)
            DataName = 'ShippingCodaData_PINCHY';
        case(13)
            DataName = 'ShippingCodaData_SAM';
        case(14)
            DataName = 'ShippingCodaData_LAIUS';
        case(15)
            DataName = 'ShippingCodaData_SOPH';
        case(16)
            DataName = 'ShippingCodaData_UNID';
        case(17)
            DataName = 'ShippingCodaData_FRUIT';
        case(18)
            DataName = 'ShippingCodaData_SOURSOP';
        case(19)
            DataName = 'ShippingCodaData_JOCASTA';
        case(20)
            DataName = 'ShippingCodaData_LADYO';
        case(21)
            DataName = 'ShippingCodaData_SALLY';
    end

    %% Loading Features
    % load sampled features
    load(DataName);

    if length(ClickVessel) > MinNumVesselSample
        DidDataSet(DataSetInd) = 1;
        num_samples_vessel = length(ClickVessel);
        X_vessel = zeros(num_samples_vessel, NUM_FEATURES);
        for ind = 1: num_samples_vessel
            X_vessel(ind,1) = ClickVessel{ind}.nClicks;
            X_vessel(ind,2) = ClickVessel{ind}.Duration;
            X_vessel(ind,3) = ClickVessel{ind}.ICI1;
            X_vessel(ind,4) = ClickVessel{ind}.ICI2;
            X_vessel(ind,5) = ClickVessel{ind}.ICI3;
            X_vessel(ind,6) = ClickVessel{ind}.ICI4;
            X_vessel(ind,7) = ClickVessel{ind}.IPI1;
            X_vessel(ind,8) = ClickVessel{ind}.IPI2;
            X_vessel(ind,9) = ClickVessel{ind}.IPI3;
            X_vessel(ind,10) = ClickVessel{ind}.IPI4;
        end

        num_samples_novessel = length(ClickNoVessel);
        X_novessel = zeros(num_samples_novessel, NUM_FEATURES);
        for ind = 1: num_samples_novessel
            X_novessel(ind,1) = ClickNoVessel{ind}.nClicks;
            X_novessel(ind,2) = ClickNoVessel{ind}.Duration;
            X_novessel(ind,3) = ClickNoVessel{ind}.ICI1;
            X_novessel(ind,4) = ClickNoVessel{ind}.ICI2;
            X_novessel(ind,5) = ClickNoVessel{ind}.ICI3;
            X_novessel(ind,6) = ClickNoVessel{ind}.ICI4;
            X_novessel(ind,7) = ClickNoVessel{ind}.IPI1;
            X_novessel(ind,8) = ClickNoVessel{ind}.IPI2;
            X_novessel(ind,9) = ClickNoVessel{ind}.IPI3;
            X_novessel(ind,10) = ClickNoVessel{ind}.IPI4;
        end

        %balance
        if 0
            NoVesselNotakePresentage = 0;
            pos = randperm(num_samples_novessel);
            loc = pos(1: floor((1-NoVesselNotakePresentage)*num_samples_novessel));
            X_novessel = X_novessel(loc, :);
        end

        KernelChosen = KernelChosenVec{1};

        for FeatureID = 1: FeatureNum
            FeatureID
            

            TestTP = zeros(1, TestSimNum);
            TestFN = zeros(1, TestSimNum);
            TestTN = zeros(1, TestSimNum);
            TestFP = zeros(1, TestSimNum);
            for TestingSimInd = 1: TestSimNum

                % Training + Validation set
                pos = randperm(num_samples_vessel);
                loc_train_vessel = pos(1: floor((1-TestPrecentage)*num_samples_vessel));
                loc_test_vessel = pos(floor((1-TestPrecentage)*num_samples_vessel)+1: end);
                pos = randperm(num_samples_novessel);
                loc_train_novessel = pos(1: floor((1-TestPrecentage)*num_samples_novessel));
                loc_test_novessel = pos(floor((1-TestPrecentage)*num_samples_novessel)+1: end);

                X_train_and_val = [X_vessel(loc_train_vessel,:); X_novessel(loc_train_novessel,:)];
                labels_train_and_val = [ones(length(loc_train_vessel),1); zeros(length(loc_train_novessel),1)];
                num_training_samples = length(labels_train_and_val);

                X_test = [X_vessel(loc_test_vessel,:); X_novessel(loc_test_novessel,:)];
                labels_test = [ones(length(loc_test_vessel),1); zeros(length(loc_test_novessel),1)];

                %% Compute PCA matrix
                coeff = pca(X_train_and_val);

                %% Divide into train/validation 75:25
                num_val_samples = num_training_samples*KFold;

                val_accuracy = zeros(1, TrainSimNum);
                ModelStruct = {};
                for TrainSimInd = 1: TrainSimNum
                    rand_num = randperm(uint32(num_training_samples));

                    val_threshold_idx = uint32(num_val_samples);

                    X_val = X_train_and_val(rand_num(1:val_threshold_idx), :);
                    labels_val = labels_train_and_val(rand_num(1:val_threshold_idx), :);

                    X_train = X_train_and_val(rand_num(val_threshold_idx+1:end), :);
                    labels_train = labels_train_and_val(rand_num(val_threshold_idx+1:end), :);

                    %% Creating K-fold validation sets
                    % Number of validation sets
                    c = cvpartition(labels_train, 'k', VALIDATION_SET_NUM);

                    % K-Fold Cross-validation (K=VALIDATION_SET_NUM) to find best
                    % FEATURES_TO_SELECT features for classifier. If mannual selection is
                    % needed, look at the begining of the next section.
                    fun = @(train_data, train_labels, test_data, test_labels)...
                        sum(predict(fitcsvm(train_data, train_labels, 'KernelFunction', KernelChosen), test_data) ~= test_labels);
                    %opts = statset('display', 'iter');
                    %[fs, history] = sequentialfs(fun, X_train, labels_train, 'cv', c, 'options', opts, 'nfeatures', FEATURES_TO_SELECT);
                    if FeatureID == 12
                        [fs, history] = sequentialfs(fun, X_train, labels_train, 'cv', c, 'nfeatures', FEATURES_TO_SELECT);
                    elseif FeatureID == 11
                        fs = logical(ones(1, NUM_FEATURES));
                    else
                        fs = logical(ones(1, NUM_FEATURES));
                        fs(FeatureID) = logical(0);
                    end

                    %% Training model
                    X_train_w_best_features = X_train(:, fs);

                    model = fitcsvm(X_train_w_best_features, labels_train, 'KernelFunction', KernelChosen,...
                        'OptimizeHyperparameters', 'auto', ...
                        'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', ...
                        'expected-improvement-plus', 'ShowPlots', false));
                    %% Validate Model
                    X_val_w_best_features = X_val(:, fs);

                    val_accuracy(TrainSimInd) = sum(predict(model, X_val_w_best_features) == labels_val)/length(labels_val)*100;
                    ModelStruct{TrainSimInd} = model;
                end

                [~,Loc] = max(val_accuracy);
                model = ModelStruct{Loc};

                % Compute precsion-recall graph
                [~,score] = predict(model, X_val_w_best_features);

                [~,score_svm] = resubPredict(model);

                if PlotFlag
                    [x_val, Y_val] = perfcurve(labels_val, score(:,2), 1, 'XCrit', 'tpr', 'YCrit', 'prec');
                    [x_train, Y_train] = perfcurve(labels_train, score_svm(:,2), 1, 'XCrit', 'tpr', 'YCrit', 'prec');
                    figure(1)
                    plot(x_val, Y_val, x_train, Y_train);
                    xlabel('Recall')
                    ylabel('Precision')
                    title('Precision-Recall (SVM model w. 4 features)')
                    legend('Validation', 'Train')
                    xlim([0, 1])
                    ylim([0, 1])
                end
                %% Test model on validation
                X_train_w_best_features = X_train(:, fs);
                pred_train = predict(model, X_train_w_best_features);
                pred_train_txt = strings([length(pred_train),1]);
                train_accuracy = sum(pred_train == labels_train)/length(labels_train)*100;

                if PlotFlag
                    figure;
                    confusion_matrix_train = confusionmat(labels_train,pred_train);
                    train_confusion = confusionchart(confusion_matrix_train,{'No Boat','Boat'});
                    train_confusion.Title = 'Training confusion matrix';
                    train_confusion.RowSummary = 'row-normalized';
                    train_confusion.ColumnSummary = 'column-normalized';
                end

                %% Test model
                X_test_w_best_features = X_test(:, fs);
                pred_test = predict(model, X_test_w_best_features);
                test_accuracy = sum(pred_test == labels_test)/length(labels_test)*100;

                if PlotFlag
                    figure;
                    confusion_matrix_test = confusionmat(labels_test,pred_test)
                    test_confusion = confusionchart(confusion_matrix_test,{'No Boat','Boat'});
                    test_confusion.Title = 'Test confusion matrix';
                    test_confusion.RowSummary = 'row-normalized';
                    test_confusion.ColumnSummary = 'column-normalized';
                end

                loc = find(labels_test == 1);
                TestTP(TestingSimInd) = sum(pred_test(loc) == labels_test(loc))/length(loc)*100;
                TestFN(TestingSimInd) = sum(pred_test(loc) ~= labels_test(loc))/length(loc)*100;
                loc = find(labels_test == 0);
                TestTN(TestingSimInd) = sum(pred_test(loc) == labels_test(loc))/length(loc)*100;
                TestFP(TestingSimInd) = sum(pred_test(loc) ~= labels_test(loc))/length(loc)*100;

            end

            TestTPMat(DataSetInd, FeatureID) = mean(TestTP);
            TestFNMat(DataSetInd, FeatureID) = mean(TestFN);
            TestTNMat(DataSetInd, FeatureID) = mean(TestTN);
            TestFPMat(DataSetInd, FeatureID) = mean(TestFP);
        end
    end
end

save('ClassRes', 'TestTPMat', 'TestFNMat', 'TestTNMat', 'TestFPMat');