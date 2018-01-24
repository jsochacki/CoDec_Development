function [EsNo_dB EVM_dB] = EsNo_and_EVM(reference, signal)
    PERROR_Vector=[]; PREF_Vector=[];

    VERROR=[];
    VERROR=signal-reference;
    PERROR_Vector=VERROR.*VERROR'.';
    PREF_Vector=reference.*reference'.';

    RMS_PERROR=sqrt((1/length(PERROR_Vector))*sum(PERROR_Vector));
    RMS_PREF=sqrt((1/length(PREF_Vector))*sum(PREF_Vector));
    EsNo_dB=10*log10(RMS_PREF/RMS_PERROR);

    %%% Calculate EVM
    EVM_dB=10*log10(RMS_PERROR/RMS_PREF);
end