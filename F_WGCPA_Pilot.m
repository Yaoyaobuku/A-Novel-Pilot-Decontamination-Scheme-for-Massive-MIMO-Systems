function P_output = F_WGCPA_Pilot(L, K, S, Beta)

    eta = zeros(L,K,L,K);
    for i1 = 1:L                                                            % pilot contamination strength calculation
        for k1 = 1:K
            for i2 = 1:L
                for k2 = 1:K
                    if (i1~=i2)
                        eta(i1,k1,i2,k2) = Beta(k1,i2,i1)^2/Beta(k2,i2,i2)^2+Beta(k2,i1,i2)^2/Beta(k1,i1,i1)^2;
                    end
                end
            end
        end
    end
    P = zeros(L, K);
    eta_max = 0;
    for j_bs = 1:L                                                          % First 2 users pilot assignment
        for k_user = 1:K
            for j1_bs = 1:L
                for k1_user = 1:K
                    if j_bs~=j1_bs && eta(j_bs,k_user,j1_bs,k1_user)>eta_max
                        j_0 = j_bs;
                        k_0 = k_user;
                        j_1 = j1_bs;
                        k_1 = k1_user;
                        eta_max = eta(j_bs,k_user,j1_bs,k1_user);
                    end
                end
            end
        end
    end
    P(j_0,k_0) = 1;
    P(j_1,k_1) = 2;

    for t = 3:L*K                                                           % Pilot assignment for other users
        delta = zeros(L,K);                                                 % UE selection
        delta_max = 0;
        for j = 1:L
            for k = 1:K
                if P(j,k) == 0
                    for j1 = 1:L
                        for k1 = 1:K
                            if j~=j1 && P(j1,k1)>0
                                delta(j,k) = delta(j,k) + eta(j,k,j1,k1);
                            end
                        end
                    end
                    if delta(j,k)>delta_max
                        j_0 = j;
                        k_0 = k;
                        delta_max = delta(j,k);
                    end
                end
            end
        end

        % Pilot selection
        c = zeros(1,S);
        for k = 1:K
            if P(j_0,k)>0
                c(P(j_0,k)) = 1;
            end
        end
        zeta = zeros(1,S);
        for j = 1:L
            for k = 1:K
                if P(j,k)>0
                    zeta(P(j,k)) = zeta(P(j,k)) + eta(j,k,j_0,k_0);
                end
            end
        end
        zeta_min = 1000;
        c0 = 0;
        for k = 1:S
            if zeta(k)<zeta_min && c(k)==0
                zeta_min = zeta(k);
                c0 = k;
            end
        end
        P(j_0,k_0) = c0;
    end
    
    P_output = P;
end