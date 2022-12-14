
ex_taxa_abun <- ex_taxa_abun[, c("ERR321132", "SRR5127690", "SRR2992922", "ERR321066")]

test_features1 <- c("SRR769509_bin.3", "21673_4_5", "SRR3992981_bin.16")
test_features2 <- c("ERR1620320_bin.20", "ERR1293861_bin.21", "SRR4408017_bin.22", "SRR2155382_bin.36", "ERR1620320_bin.43")

test_features_w_missing <- c("ERR1620320_bin.20", "ERR1293861_bin.21", "not_present")
test_features_w_overlapping <- c("ERR1620320_bin.20", "ERR1293861_bin.21", "21673_4_5")

test_that("expected error returned when features not present in table are input.", {
  expect_error(object = abun_isometric_log_ratios(abun_table = ex_taxa_abun,
                                                  set1_features = test_features1,
                                                  set2_features = test_features_w_missing),
               regexp = "Stopping - at least one feature in the specified sets is not present as a row name in the abundance table.")
})


test_that("expected error returned when features intersecting between sets.", {
  expect_error(object = abun_isometric_log_ratios(abun_table = ex_taxa_abun,
                                                  set1_features = test_features1,
                                                  set2_features = test_features_w_overlapping),
               regexp = "Stopping - at least one feature overlaps between the input sets.")
})


test_that("error related to presence of 0's occurs in absence of pseudocount", {
  expect_error(object = abun_isometric_log_ratios(abun_table = ex_taxa_abun,
                                                  set1_features = test_features1,
                                                  set2_features = test_features2,
                                                  pseudocount = 0),
               regexp = "At least one 0 is present in the abundance table, which means that at least some isometric log ratios cannot be computed.")
})


test_that("ILR values make sense for test case.", {
  
  expected_output <- c(1.622685042, 1.263703782, 0.000000000, -0.012730004)
  names(expected_output) <- c("ERR321132", "SRR5127690", "SRR2992922", "ERR321066")
  
  expect_equal(object = abun_isometric_log_ratios(abun_table = ex_taxa_abun,
                                                  set1_features = test_features1,
                                                  set2_features = test_features2,
                                                  pseudocount = 1),
               expected = expected_output,
               tolerance = 0.000000001)
})



test_that("compute_node_balances check balances at one node with all default settings.", {
  
  balances_out <- compute_node_balances(tree = ex_tree,
                                        abun_table = ex_taxa_abun,
                                        min_num_tips=5,
                                        ncores=1,
                                        pseudocount=1)
  
  expect_equal(as.numeric(balances_out$balances$n2),
               c(0.452007703, 0.098400066, 0.339260067, 0.167928196),
               tolerance = 0.000000001)
  
})


test_that("compute_node_balances error when no node labels.", {
  
  ex_tree$node.label <- NULL
  
  expect_error(object = compute_node_balances(tree = ex_tree,
                                              abun_table = ex_taxa_abun,
                                              min_num_tips=5,
                                              ncores=1,
                                              pseudocount=1),
               regexp = "Stopping - input tree does not have any node labels.")

})


test_that("compute_node_balances error when tip not found as row name.", {
  
  ex_tree$tip.label[1] <- "test"
  
  expect_error(object = compute_node_balances(tree = ex_tree,
                                              abun_table = ex_taxa_abun,
                                              min_num_tips=5,
                                              ncores=1,
                                              pseudocount=1),
               regexp = "Stopping - not all tips are found as row names in the abundance table.")
  
})


test_that("compute_node_balances error when node name in subset_to_test not found in tree.", {
  
  expect_error(object = compute_node_balances(tree = ex_tree,
                                              abun_table = ex_taxa_abun,
                                              min_num_tips=5,
                                              ncores=1,
                                              pseudocount=1,
                                              subset_to_test = c("n1", "n2", "n1000")),
               regexp = "Stopping - some labels in subset_to_test do not match node labels in the tree.")
  
})


test_that("compute_node_balances change min number of tips to make sure that's working.", {
  
  balances_out <- compute_node_balances(tree = ex_tree,
                                        abun_table = ex_taxa_abun,
                                        min_num_tips=2,
                                        ncores=1,
                                        pseudocount=1)
  
  expect_equal(as.numeric(balances_out$balances$n47),
               c(0.20217048, -0.52710781, -0.70255869, 0.00000000),
               tolerance = 0.00000001)
  
})


test_that("compute_node_balances try subset_to_test with nodes present and no nodes that pass the min_num_tips", {
  
  expect_error(object = compute_node_balances(tree = ex_tree,
                                              abun_table = ex_taxa_abun,
                                              min_num_tips=5,
                                              ncores=1,
                                              pseudocount=1,
                                              subset_to_test = c("n3", "n8", "n13")),
               regexp = "Stopping - no non-negligible nodes remain after filtering based on mininum number of tips on left and right-hand side of each node.")
  
})


test_that("compute_node_balances try altering pseudocount to make sure that parameter is working as expected.", {
  
  balances_out <- compute_node_balances(tree = ex_tree,
                                        abun_table = ex_taxa_abun,
                                        min_num_tips=5,
                                        ncores=1,
                                        pseudocount=0.1)
  
  expect_equal(as.numeric(balances_out$balances$n2),
               c(0.636116099, 0.160104447, 0.987249903, 0.389099558),
               tolerance = 0.000000001)
  
})



test_that("compute_node_balances will dereplicate nodes correctly, cutoff = 0.75.", {
  
  balances_out <- compute_node_balances(tree = ex_tree,
                                        abun_table = ex_taxa_abun,
                                        min_num_tips=5,
                                        ncores=1,
                                        pseudocount=1,
                                        derep_nodes = TRUE,
                                        jaccard_cutoff = 0.75)
  
  expect_equal(balances_out$ignored_redundant_nodes, "n20")
  
})


test_that("compute_node_balances will dereplicate nodes correctly, cutoff = 0.5.", {
  
  balances_out <- compute_node_balances(tree = ex_tree,
                                        abun_table = ex_taxa_abun,
                                        min_num_tips=5,
                                        ncores=1,
                                        pseudocount=1,
                                        derep_nodes = TRUE,
                                        jaccard_cutoff = 0.5)
  
  expect_equal(balances_out$node_clusters[[1]], c("n1", "n18", "n20", "n25", "n32"))
  
})
