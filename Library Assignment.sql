USE Master
GO
 /*Checking to ensure that this database doesn't already exist*/
 
If Exists(SELECT* FROM sysdatabases
			WHERE Name = 'dbLibrary')
			
DROP Database dbLibrary  --Remove DB if it exists
GO
--Create New Instance of DB
CREATE Database dbLibrary
GO
--Ensure using correct DB
USE dbLibrary
GO
--Making first table

--Title Table
CREATE TABLE Title
(
	BPrimary_ID int not null,
	BookId int primary key,
	Title varchar(50) not null,
	PublisherName varchar(50) null
)
GO

--Authors Table
Create TABLE BookAuthors
(
	P_ID int primary key,
	BookId int foreign key REFERENCES Title(BookID),
	AuthorName varchar(50) not null
)
GO

--Publishers Table
Create TABLE Publisher
(
	PublisherID int primary key,
	PublisherName varchar(50) not null,
	P_Address varchar(75) not null,
	P_Phone varchar(20) null
)
GO


--Library Branch Table
CREATE TABLE LibraryBranch
(
	BranchID int primary key,
	BranchName Varchar(50) not null,
	Br_Address Varchar(75) not null,
	L_Librarian Varchar(50) not null
)
GO

--Copies of Books that each Library owns
CREATE TABLE BookCopies
(
	Copies_ID int primary key,
	BookID int foreign key REFERENCES Title(BookID),
	BranchID int foreign key REFERENCES LibraryBranch(BranchID),
	NumberOfCopies int not null
)
GO


--Library User Information
CREATE TABLE Borrowers
(
	CardNumber int primary key,
	Name Varchar(50) not null,
	[Address] Varchar(75) not null,
	Phone Varchar(20) not null
)
GO

--Books out on loan to Library Users
CREATE TABLE Bookloans
(
	Out_ID int primary key,
	BookID int foreign key REFERENCES Title(BookID),
	BranchID int foreign key REFERENCES LibraryBranch(BranchID),
	CardNumber int foreign key REFERENCES Borrowers(Cardnumber),
	CheckOut Varchar(20) not null,
	DueDate Varchar(20) not null
)
GO


--Book Title Information
BULK INSERT Title
FROM 'C:\Users\Owner\Desktop\Library\Title.txt'
With
(
	firstrow = 2,
	Rowterminator = '\n',
	Tablock
)
GO

--Book Author Information
BULK INSERT BookAuthors
FROM 'C:\Users\Owner\Desktop\Library\BookAuthor.txt'
With
(
	firstrow = 2,
	Rowterminator = '\n',
	Tablock
)
GO

--Book Copies Information
BULK INSERT BookCopies
FROM 'C:\Users\Owner\Desktop\Library\BookCopies.txt'
With
(
	firstrow = 2,
	Rowterminator = '\n',
	Tablock
)
GO


--Book Loans Information
BULK INSERT BookLoans
FROM 'C:\Users\Owner\Desktop\Library\BookLoans.txt'
With
(
	firstrow = 2,
	Rowterminator = '\n',
	Tablock
)
GO


--Book Borrowers Information
BULK INSERT Borrowers
FROM 'C:\Users\Owner\Desktop\Library\Borrowers.txt'
With
(
	firstrow = 2,
	Rowterminator = '\n',
	Tablock
)
GO

--Branch Information
BULK INSERT LibraryBranch
FROM 'C:\Users\Owner\Desktop\Library\Bookbranch.txt'
With
(
	firstrow = 2,
	Rowterminator = '\n',
	Tablock
)
GO

--Book Publisher Information
BULK INSERT Publisher
FROM 'C:\Users\Owner\Desktop\Library\Publisher.txt'
With
(
	firstrow = 2,
	Rowterminator = '\n',
	Tablock
)
GO

--1 Procedure for determining how many copies of The Lost Tribe
CREATE PROC GetLostTribeSharpstown
AS
SELECT LB.BranchName, T.BookID, T.Title, BC.NumberOfCopies
FROM BookCopies BC Join LibraryBranch LB on BC.BranchID = LB.BranchID
JOIN Title T on BC.BookID=T.BookId 
WHERE T.BookId = 9  
AND LB.BranchName = 'Sharpstown'
Go


--2 Procedure to determined how many copies each branch has of The Lost Tribe
Create Proc GetLostTribeAll
AS
SELECT LB.BranchName, T.BookID, T.Title, BC.NumberOfCopies
FROM BookCopies BC Join LibraryBranch LB on BC.BranchID = LB.BranchID
JOIN Title T on BC.BookID=T.BookId 
WHERE T.BookId = 9 
Go


--3 Procedure for all Borrowers with no books checked out
Create Proc GetBorrowersNoBooks
As
SELECT BR.Name As Name, Count(BL.CardNumber) As [Books Checked Out]
From Borrowers BR left outer Join BookLoans BL on BR.CardNumber = BL.CardNumber
Where BL.CardNumber is null
Group By BR.Name, BL.CardNumber 
ORDER BY BR.Name, BL.CardNumber
GO


--4 Procedure for books loaned out to Sharpstown whose DueDate is Today
CREATE PROC GetBooksDueTodaySharpstown
AS
DECLARE @Today date
SET @Today = GetDate()
SELECT T.Title, BL.DueDate, BR.Name, BR.[Address]
FROM BookLoans BL Join LibraryBranch LB on BL.BranchID = LB.BranchID
JOIN Title T on BL.BookID = T.BookId join Borrowers BR on BL.CardNumber = BR.CardNumber
WHERE LB.BranchName = 'Sharpstown'
AND DueDate=@Today
GO

--5 Procedure for how many books are checked out from each branch
CREATE PROC  GetBooksCheckedOutAll
AS
SELECT LB.BranchName, Count(CheckOut) As Checked_Out  
FROM LibraryBranch AS LB   
INNER JOIN BookLoans AS BL  
ON LB.BranchID = BL.BranchID 
GROUP BY LB.BranchName 
GO

--6 Procedure for showing borrowers who have 5 or more books checked out
CREATE PROC  GetBorrowers5Books
AS
SELECT BR.Name As Name, BR.[Address] As [Address], Count(BL.Checkout) As [Checked Out]
FROM Borrowers BR Join BookLoans BL on BR.CardNumber = BL.CardNumber
GROUP BY BR.Name, BR.[Address] 
HAVING Count(BL.Checkout) >= 5
GO

--7 Procedure for how many copies of Stephen Kings Book(s) @ Central
CREATE PROC  GetKingBooksCentral
AS
SELECT LB.BranchName, BA.AuthorName, T.Title, BC.NumberOfCopies
FROM BookCopies BC Join LibraryBranch LB on BC.BranchID = LB.BranchID
JOIN Title T on BC.BookID = T.BookId Join BookAuthors BA on T.BookId = BA.BookId
WHERE BA.AuthorName = 'Stephen King' AND LB.BranchName = 'Central'

