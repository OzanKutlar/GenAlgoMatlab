function [fit_array_archive] = truncate_archive(fit_array_archive,densityArray)
global gas;
i = 1;j = 1;
    if size(fit_array_archive,1) > gas.n_archive
        while size(fit_array_archive,1) > gas.n_archive
            if i==j
                j = j+ 1;
                continue;
            end
            if fit_array_archive(i,6) == fit_array_archive(j,6)
                fit_array_archive(i,:) = [];
            end
            if size(fit_array_archive,1) == gas.n_archive
                break;
            end
            j = j +1;
            if j > size(fit_array_archive,1)
                j = 1;
                i = i + 1;
            end
            if i > size(fit_array_archive)
                i = 1;
            end
        end
    end
end