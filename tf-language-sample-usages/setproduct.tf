locals {
  arr_a = [1, 2, 3]
  arr_b = ["a", "b"]

  product_ab = setproduct(local.arr_a, local.arr_b)
}

output "a6" {
  value = local.product_ab
}

resource "local_file" "generated" {
  filename = "${path.module}/setproduct.tf.out"

  content = jsonencode(local.product_ab)
}
