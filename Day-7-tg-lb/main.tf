resource "aws_lb_target_group" "target-group" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0bd164ef13514e3ac"
  
}

resource "aws_lb" "lb" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-0d879441838957ac1", "subnet-016f2352d37cba14b"]
 
  tags = {
    Name = "ALB-Frontend"
  }
  depends_on = [ aws_lb_target_group.target-group ]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
  depends_on = [ aws_lb_target_group.target-group ]
}