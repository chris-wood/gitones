require 'rsruby'

cmd = %Q
(
  pdf(file = "r_directly.pdf"))
  boxplot(c(1,2,3,4),c(5,6,7,8))
  dev.off()
)

r = RSRuby.instance
r.eval_R(cmd)
