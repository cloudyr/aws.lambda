get_col <- function(data, nrow, ncol, colnum) {
  Matrix::Matrix(data, nrow, ncol)[, colnum]
}
