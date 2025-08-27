# Internal ALB Security Group
resource "aws_security_group" "internal_alb_sg" {
  name_prefix = "internal-alb-sg"
  description = "Security group for internal ALB"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from frontend instances
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.Frontend_SG.id] # Reference your frontend SG
  }

  # Allow outbound to backend instances
  egress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]  # Reference the VPC
  }

  tags = {
    Name = "internal-alb-sg"
  }
}
    # Load Balancer SG

    resource "aws_security_group" "LB_SG"{
        name = "LB_SG" 
        description = "this is the security group at the load balancer"
        vpc_id = aws_vpc.main.id
    
        egress {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    # Frontend SG

    resource "aws_security_group" "Frontend_SG" {
        name = "Frontend_SG"  
        description = "this is the security group at the presentation layer"
        vpc_id = aws_vpc.main.id
        ingress {
            description = "allow HTTP from the Load Balancer SG" 
            from_port        = 80
            to_port          = 80
            protocol         = "tcp"
            security_groups = [aws_security_group.LB_SG.id] 
        }
        ingress {
            description = "allow SSH from a specific IP" 
            from_port        = 22
            to_port          = 22
            protocol         = "tcp" 
            cidr_blocks      = ["0.0.0.0/0"] # <-- !!!!!!!! accessible ssh from anywhere, REPLACE with your actual IP for security
        }
        egress {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    # Backend SG

    resource "aws_security_group" "Backend_SG" {
        name = "Backend_SG"
        description = "this is the security group at the application layer"
        vpc_id = aws_vpc.main.id
        ingress {
            description = "allow some required application port communication from the Frontend_SG" 
            from_port        = 3001 #randomly chosen port, the actual app port will be set later
            to_port          = 3001
            protocol         = "tcp"
            security_groups = [aws_security_group.internal_alb_sg.id]
        }
        ingress {
            description = "allow SSH from the Frontend SG" 
            from_port        = 22
            to_port          = 22
            protocol         = "tcp"
            security_groups = [aws_security_group.Frontend_SG.id]
        }
        egress {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    resource "aws_security_group" "DB_SG" {
        name = "DB_SG"
        description = "this is the security group at the database layer"
        vpc_id = aws_vpc.main.id
        ingress {
            description = "allow some required appliction port communication from the Backend_SG" 
            from_port        = 3306 
            to_port          = 3306
            protocol         = "tcp"
            security_groups = [aws_security_group.Backend_SG.id]
        }
        egress {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

#----------------------------------------------------------------------------------------------------------


