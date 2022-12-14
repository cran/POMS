
pairwise_mean_direction_and_wilcoxon <- function(in_list, group1, group2, corr_method="BH", ncores=1, skip_wilcoxon=FALSE) {
  
  # Run two-group Wilcoxon tests.
  # Will run separate test for each separate element of input list.
  
  wilcox_output <- list()
  mean_direction <- as.character()
  
  if (skip_wilcoxon) {
  
    wilcox_corrected_p <- NULL
    wilcox_raw_p <- NULL
    
    result <- parallel::mclapply(names(in_list), function(x) {
      
                    group1_mean <- mean(in_list[[x]][group1])
                    group2_mean <- mean(in_list[[x]][group2])
                      
                    if(group1_mean > group2_mean) {
                      mean_direction <- c(mean_direction, "group1")
                    } else if(group1_mean < group2_mean) {
                      mean_direction <- c(mean_direction, "group2")
                    } else if(group1_mean == group2_mean) {
                      mean_direction <- c(mean_direction, "same")
                      warning(paste("The calculated means are exactly the same for each group for test ", x, ", which likely indicates a problem.", sep=""))
                    }
                
                      return(mean_direction)
                    }, mc.cores=ncores)
    
    for(i in 1:length(result)) {
      mean_direction <- c(mean_direction, result[[i]])
    }
    
    
  } else {
    result <- parallel::mclapply(names(in_list), function(x) {
                    wilcox_out <- stats::wilcox.test(in_list[[x]][group1], in_list[[x]][group2], exact=FALSE)
                    
                    group1_mean <- mean(in_list[[x]][group1])
                    group2_mean <- mean(in_list[[x]][group2])
                    
                    if(group1_mean > group2_mean) {
                      mean_direction <- c(mean_direction, "group1")
                    } else if(group1_mean < group2_mean) {
                      mean_direction <- c(mean_direction, "group2")
                    } else if(group1_mean == group2_mean) {
                      mean_direction <- c(mean_direction, "same")
                      warning(paste("The calculated means are exactly the same for each group for test ", x, ", which likely indicates a problem.", sep=""))
                    }
                    
                    return(list(wilcox_out = wilcox_out, mean_direction = mean_direction))
                  }, mc.cores = ncores)
    
    wilcox_raw_p <- as.numeric()
    
    for(i in 1:length(result)) {
      wilcox_raw_p <- c(wilcox_raw_p, result[[i]]$wilcox_out$p.value)
      wilcox_output[[i]] <- result[[i]]$wilcox_out
      mean_direction <- c(mean_direction, result[[i]]$mean_direction)
    }
    
    wilcox_corrected_p <- stats::p.adjust(p = wilcox_raw_p, method = corr_method)
    
    names(wilcox_raw_p) <- names(in_list)
    names(wilcox_corrected_p) <- names(in_list)
    names(wilcox_output) <- names(in_list)
  }
  
  names(mean_direction) <- names(in_list)
  
  return(list(mean_direction = mean_direction,
              wilcox_raw_p = wilcox_raw_p,
              wilcox_corrected_p = wilcox_corrected_p,
              wilcox_output = wilcox_output))
  
}
