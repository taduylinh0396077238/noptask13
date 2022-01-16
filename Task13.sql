Create Database CitySoftware
go
USE CitySoftware
go

-- Tạo Bảng
Create Table Employee(
	EmployeeID int primary key,
	Name varchar(100),
	Tel char(11),
	Email varchar(30)
)
go

Create Table Project (
	ProjectID int primary key,
	ProjectName varchar(30),
	StartDate datetime ,
	EndDate datetime ,
	Period int ,
	Cost money
)
GO

Create Table Groups (
	GroupID int primary key,
	GroupName varchar(30),
	LeaderID int foreign key references Employee(EmployeeID),
	ProjectID int foreign key references Project(ProjectID)
)
Go

Create Table GroupDetail (
	GroupID int foreign key references Groups(GroupID),
	EmployeeID int foreign key references Employee(EmployeeID),
	Status char(20)
)
Go

-- YÊU CẦU
-- 2. Thêm dữ liệu cho các bảng
Insert Into Employee Values(1,'Nguyen Van Sinh','098657431','email@gmail.com'),
						   (2,'Đinh Hoang Long','077657431','email@gmail.com'),
						   (3,'Pham Thi Men','033657431','email@gmail.com'),
						   (4,'Luong Van An','078657431','email@gmail.com'),
						   (5,'Phan Van Tinh','068657431','email@gmail.com')
Go

Insert Into Project Values(1,'Open City','2020/02/15','2021/09/18',18,2000),
						  (2,'Deco park','2020/01/28','2022/01/05',24,9000),
						  (3,'FLC Gof','2019/02/25','2021/02/20',32,7000)
GO

Insert Into Groups Values(1,'GTOP1',1,1),
						 (2,'GTOP2',2,2),
						 (3,'GTOP3',3,3)
Go

Insert Into GroupDetail Values(1,1,'Dang Lam'),
							  (2,2,'Dang Lam'),
							  (3,3,'Dang Lam'),
							  (2,4,'Dang Lam'),
							  (3,5,'Dang Lam')
GO
Select * From GroupDetail
Select * From Groups
-- 3. Viết câu lệnh truy vấn để:
-- a. Hiển thị thông tin của tất cả nhân viên
Select * From Employee
GO
-- b. Liệt kê danh sách nhân viên đang làm dự án “Deco park”
Select * From Employee inner Join GroupDetail
ON Employee.EmployeeID = GroupDetail.EmployeeID
inner Join Groups On GroupDetail.GroupID = Groups.GroupID
inner Join Project ON Project.ProjectID = Groups.ProjectID
Where Project.ProjectID = 2
Go
-- c. Thống kê số lượng nhân viên đang làm việc tại mỗi nhóm
Select Groups.GroupName, COUNT(*) [SLNV]
From Groups Join GroupDetail
ON Groups.GroupID = GroupDetail.GroupID
Group bY Groups.GroupName
GO
-- d. Liệt kê thông tin cá nhân của các trưởng nhóm
Select *
From Groups Join Employee
ON Groups.LeaderID = Employee.EmployeeID
Go
-- e. Liệt kê thông tin về nhóm và nhân viên đang làm các dự án có ngày bắt đầu làm trước ngày 12/10/2010
Select a.Name,b.GroupName,d.ProjectName From  Employee a join GroupDetail c
ON a.EmployeeID = c.EmployeeID
Join Groups b ON c.GroupID = b.GroupID
Join Project d ON d.ProjectID = b.ProjectID
Where d.StartDate < '2020/01/20' 
go
-- f. Liệt kê tất cả nhân viên dự kiến sẽ được phân vào các nhóm làm việc
Select a.Name,b.GroupName From  Employee a join GroupDetail c
ON a.EmployeeID = c.EmployeeID
Join Groups b ON c.GroupID = b.GroupID
GO
-- g. Liệt kê tất cả thông tin về nhân viên, nhóm làm việc, dự án của những dự án đã hoàn thành
Select * From  Employee a join GroupDetail c
ON a.EmployeeID = c.EmployeeID
Join Groups b ON c.GroupID = b.GroupID
Join Project d ON d.ProjectID = b.ProjectID
Where d.EndDate <= '2022/01/13' 
go

--4 Viết câu lệnh kiểm tra:
-- a. Ngày hoàn thành dự án phải sau ngày bắt đầu dự án
Alter table Project
 ADD CONSTRAINT dat_e check (EndDate > StartDate)
 Go
-- b. Trường tên nhân viên không được null
Alter Table Employee 
	Alter column Name varchar(100) not null
Go
-- c. Trường trạng thái làm việc chỉ nhận một trong 3 giá trị: inprogress, pending, done
Alter Table GroupDetail
	Add constraint sta_tus Check(Status In ('inprogress','pending','done'))
Go
-- d. Trường giá trị dự án phải lớn hơn 1000
Alter Table Project
	Add Constraint Du_an Check(Cost > 1000)
GO
-- e. Trưởng nhóm làm việc phải là nhân viên
Alter Table Groups 
	ADD Constraint t_k LeaderID int foreign key references Employee(EmployeeID)
GO
-- f. Trường điện thoại của nhân viên chỉ được nhập số và phải bắt đầu bằng số 0
Alter table Employee 
	ADD Constraint te_l Check (Tel Like '[0][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
Go

--5 Tạo các thủ tục lưu trữ thực hiện:
-- a. Tăng giá thêm 10% của các dự án có tổng giá trị nhỏ hơn 2000
Create Proc SP_persent
AS
	Update Project
	SET Cost = Cost * 0.1
	Where Cost < 2000
GO
-- b. Hiển thị thông tin về dự án sắp được thực hiện
Create Proc SP_Project_Featrure
AS
	Select * From Project
	Where StartDate > Getdate()
Go
-- c. Hiển thị tất cả các thông tin liên quan về các dự án đã hoàn thành
Create Proc SP_Finist
AS
	Select * From Project
	Where EndDate <= Getdate()
Go


-- 6 Tạo các chỉ mục:
-- a. Tạo chỉ mục duy nhất tên là IX_Group trên 2 trường GroupID và EmployeeID của bảng GroupDetail
Create UNIQUE INDEX IX_Group ON GroupDetail(GroupID,EmployeeID)
GO
-- b. Tạo chỉ mục tên là IX_Project trên trường ProjectName của bảng Project gồm các trường StartDate và EndDate
Create INDEX IX_Project ON Project(ProjectName,StartDate,EndDate)
GO


-- 7 Tạo các khung nhìn để
-- a. Liệt kê thông tin về nhân viên, nhóm làm việc có dự án đang thực hiện
Create View V_DangThuchien 
AS
Select a.Name,a.tel,a.Email,b.GroupName From  Employee a join GroupDetail c
ON a.EmployeeID = c.EmployeeID
Join Groups b ON c.GroupID = b.GroupID
Join Project d ON d.ProjectID = b.ProjectID
Where d.EndDate < GetDate()  
go
-- b. Tạo khung nhìn chứa các dữ liệu sau: tên Nhân viên, tên Nhóm, tên Dự án và trạng thái làm việc của Nhân viên.
Create View V_TongHop 
AS
Select a.Name , b.GroupName, d.ProjectName 
From  Employee a join GroupDetail c
ON a.EmployeeID = c.EmployeeID
Join Groups b ON c.GroupID = b.GroupID
Join Project d ON d.ProjectID = b.ProjectID
Go


-- 8 Tạo Trigger thực hiện công việc sau:
-- a. Khi trường EndDate được cập nhật thì tự động tính toán tổng thời gian hoàn thành dự án và cập nhật vào trường Period
Create Trigger Update_Period ON Project
After update 
AS
BEGIN
	Update Project 
	Set Period = DATEDIFF(m,StartDate,EndDate)
END

go
-- Test
Update Project
SET EndDate = '2022/10/14'

Select * From Project
GO
-- b. Đảm bảo rằng khi xóa một Group thì tất cả những bản ghi có liên quan trong bảng GroupDetail cũng sẽ bị xóa theo.
Create Trigger Delete_Group ON GroupDetail
For Delete
AS
Begin 
	Delete From GroupDetail
		Where GroupID In (Select * From deleted)
END	
GO
-- c. Không cho phép chèn 2 nhóm có cùng tên vào trong bảng Group.
Create Trigger Test_Insert ON Groups
For Insert
AS
Begin
	IF EXISTS (Select * From Groups a Join inserted b On a.GroupName = b.GroupName )
	Begin 
		Print 'Ten Group khong duoc trung lap !'
		Rollback Transaction 
	End
END
Go