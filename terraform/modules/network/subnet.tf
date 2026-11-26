resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[count.index]
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.name}-public-${substr(var.azs[count.index], -2, 2)}", Tier = "public" }
}

resource "aws_subnet" "app" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  availability_zone = var.azs[count.index]
  cidr_block        = var.app_cidrs[count.index]
  tags              = { Name = "${var.name}-private-app-${substr(var.azs[count.index], -2, 2)}", Tier = "private-app" }
}

resource "aws_subnet" "db" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  availability_zone = var.azs[count.index]
  cidr_block        = var.db_cidrs[count.index]
  tags              = { Name = "${var.name}-private-db-${substr(var.azs[count.index], -2, 2)}", Tier = "private-db" }
}
