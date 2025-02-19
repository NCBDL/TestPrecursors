USE [admin_acpl189_NCB_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[fnNTextToIntTable]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnNTextToIntTable] (@Data NTEXT)
RETURNS 
    @IntTable TABLE ([Value] INT NULL)
AS
BEGIN
    DECLARE @Ptr int, @Length int, @v nchar, @vv nvarchar(10)

    SELECT @Length = (DATALENGTH(@Data) / 2) + 1, @Ptr = 1

    WHILE (@Ptr < @Length)
    BEGIN
        SET @v = SUBSTRING(@Data, @Ptr, 1)

        IF @v = ','
        BEGIN
            INSERT INTO @IntTable (Value) VALUES (CAST(@vv AS int))
            SET @vv = NULL
        END
        ELSE
        BEGIN
            SET @vv = ISNULL(@vv, '') + @v
        END

        SET @Ptr = @Ptr + 1
    END

    -- If the last number was not followed by a comma, add it to the result set
    IF @vv IS NOT NULL
        INSERT INTO @IntTable (Value) VALUES (CAST(@vv AS int))

    RETURN
END

GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ConcatenateSubstances]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_ConcatenateSubstances]
(
	@urn varchar(50),
	@valueType varchar(50),
	@category int
)
returns varchar(2000)

as
begin
Declare @substance varchar(2000)
if(@valueType = 'Substance')
--Select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from (Select ControlledSubstance FROM ff_Receipt_Import R INNER JOIN ControlledSubstance_Master S ON R.CS_ID=S.CS_ID where R.URN=@urn and R.Category=@category group by ControlledSubstance)ss
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_SubstancesQtyUrnWise where URN = @urn and Category = @category 

else if(@valueType = 'Quantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, RecQty) from VW_SubstancesQtyUrnWise where URN = @urn and Category = @category 

else if(@valueType = 'Lavel2Substance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_SubstanceQtyWithURNandQuarter where URN = @urn 
group by ControlledSubstance order by ControlledSubstance

else if(@valueType = 'Lavel2Quantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, RecQty) from VW_SubstanceQtyWithURNandQuarter where URN = @urn and 
Category = @category group by ControlledSubstance, RecQty order by ControlledSubstance



else if(@valueType = 'DestroyedSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_DestroyedQty 
where urn = @urn group by ControlledSubstance  

else if(@valueType = 'DestroyedQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM(destroyedQty))  from VW_DestroyedQty 
where urn = @urn group by ControlledSubstance 

else if(@valueType = 'DestroyedSubLavel2')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_DestroyedSubstanceQty where FI_Id  = @urn

else if(@valueType = 'DestroyedQtyLevel2')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, qty) from VW_DestroyedSubstanceQty where FI_Id  = @urn



else if(@valueType = 'MFDSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_MfdWithUrn where urnNo = @urn group by ControlledSubstance

else if(@valueType = 'MFDQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM(mfdQty)) from VW_MfdWithUrn where urnNo = @urn
group by ControlledSubstance



else if(@valueType = 'SoldSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_SalesSubtanceWithUrn where urnNo = @urn group by ControlledSubstance

else if(@valueType = 'SoldQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM(soldQty)) from VW_SalesSubtanceWithUrn where urnNo = @urn 
group by ControlledSubstance


else if(@valueType = 'FormGSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ cs.ControlledSubstance from tnFormG_ConsignmentDesc con 
inner join tn_FormG fg on con.FG_Id = fg.FG_Id inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID
where fg.FG_Id = @urn group by cs.ControlledSubstance, fg.FG_Id
order by cs.ControlledSubstance

else if(@valueType = 'FormGQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM( quantity))  from tnFormG_ConsignmentDesc con 
inner join tn_FormG fg on con.FG_Id = fg.FG_Id inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID
where fg.FG_Id = @urn group by cs.ControlledSubstance, fg.FG_Id
order by cs.ControlledSubstance


else if(@valueType = 'FormHSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ cs.ControlledSubstance from fh_consignments_details con inner join tn_FormH fh on 
con.FH_ID = fh.FH_ID inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID where fh.FH_ID = @urn group by cs.ControlledSubstance, 
fh.FH_ID order by cs.ControlledSubstance

else if(@valueType = 'FormHQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM( quantity)) from fh_consignments_details con inner join tn_FormH fh 
on con.FH_ID = fh.FH_ID inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID where fh.FH_ID = @urn group by cs.ControlledSubstance, 
fh.FH_ID order by cs.ControlledSubstance

return @substance
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ConcatenateSubstances_new]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_ConcatenateSubstances_new]
(
	@urn varchar(50),
	@valueType varchar(50),
	@category int,
	@quarter int
)
returns varchar(2000)

as
begin
Declare @substance varchar(2000)
if(@valueType = 'Substance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_SubstancesQtyUrnWise where URN = @urn and Category = @category and Quater=@quarter

else if(@valueType = 'Quantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, RecQty) from VW_SubstancesQtyUrnWise where URN = @urn and Category = @category and Quater=@quarter

else if(@valueType = 'Lavel2Substance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_SubstanceQtyWithURNandQuarter where URN = @urn 
group by ControlledSubstance order by ControlledSubstance

else if(@valueType = 'Lavel2Quantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, RecQty) from VW_SubstanceQtyWithURNandQuarter where URN = @urn and 
Category = @category group by ControlledSubstance, RecQty order by ControlledSubstance



else if(@valueType = 'DestroyedSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_DestroyedQty 
where urn = @urn group by ControlledSubstance  

else if(@valueType = 'DestroyedQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM(destroyedQty))  from VW_DestroyedQty 
where urn = @urn group by ControlledSubstance 

else if(@valueType = 'DestroyedSubLavel2')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_DestroyedSubstanceQty where FI_Id  = @urn

else if(@valueType = 'DestroyedQtyLevel2')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, qty) from VW_DestroyedSubstanceQty where FI_Id  = @urn



else if(@valueType = 'MFDSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_MfdWithUrn where urnNo = @urn group by ControlledSubstance

else if(@valueType = 'MFDQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM(mfdQty)) from VW_MfdWithUrn where urnNo = @urn
group by ControlledSubstance



else if(@valueType = 'SoldSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_SalesSubtanceWithUrn where urnNo = @urn group by ControlledSubstance

else if(@valueType = 'SoldQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM(soldQty)) from VW_SalesSubtanceWithUrn where urnNo = @urn 
group by ControlledSubstance


else if(@valueType = 'FormGSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ cs.ControlledSubstance from tnFormG_ConsignmentDesc con 
inner join tn_FormG fg on con.FG_Id = fg.FG_Id inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID
where fg.FG_Id = @urn group by cs.ControlledSubstance, fg.FG_Id
order by cs.ControlledSubstance

else if(@valueType = 'FormGQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM( quantity))  from tnFormG_ConsignmentDesc con 
inner join tn_FormG fg on con.FG_Id = fg.FG_Id inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID
where fg.FG_Id = @urn group by cs.ControlledSubstance, fg.FG_Id
order by cs.ControlledSubstance


else if(@valueType = 'FormHSubstance')
select @substance=COALESCE(@substance+'<br/>','')+ cs.ControlledSubstance from fh_consignments_details con inner join tn_FormH fh on 
con.FH_ID = fh.FH_ID inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID where fh.FH_ID = @urn group by cs.ControlledSubstance, 
fh.FH_ID order by cs.ControlledSubstance

else if(@valueType = 'FormHQuantity')
select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, SUM( quantity)) from fh_consignments_details con inner join tn_FormH fh 
on con.FH_ID = fh.FH_ID inner join ControlledSubstance_Master cs on con.CS_Id = cs.CS_ID where fh.FH_ID = @urn group by cs.ControlledSubstance, 
fh.FH_ID order by cs.ControlledSubstance

return @substance
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetActivity]
(
	@ID int,
	@Address varchar(256)
)
returns varchar(100)

as
begin
Declare @activity varchar(100)
select @activity=COALESCE(@activity+',','')+CAST(NA_ID as varchar) from fb_ControlledSubstanceReg 
where FB_ID=@ID and premisesAddress=@Address

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetActivityByName]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ufn_GetActivityByName]
(
	@ID int,
	@premisesAddress varchar(256)
)
returns varchar(100)

as
begin
Declare @activity varchar(1000)
select @activity=COALESCE(@activity+'<br/>','')+na.NatureActivity+CASE WHEN OthersNA is NOT null OR OthersNA<>'' THEN '-'+OthersNA ELSE '' END 
from fb_ControlledSubstanceReg csr inner join NatureActivity_Master na ON csr.NA_ID=na.NA_ID
where csr.FB_ID=@ID and csr.premisesAddress=@premisesAddress

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetActivityByName1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ufn_GetActivityByName1]
(
	@ID int,
	@CSID int,
	@premisesAddress varchar(256)
)
returns varchar(1000)

as
begin
Declare @activity varchar(1000)
select @activity=COALESCE(@activity+'<br/>','')+REPLACE(na.NatureActivity,'(Please Specify)','')+CAsE WHEN na.NatureActivity='Other(Please Specify)' and OthersNA is not null THEN '-'+OthersNA else '' END --CASE WHEN OthersNA is NOT null OR OthersNA<>'' THEN '-'+OthersNA ELSE '' END
from fb_ControlledSubstanceReg csr inner join NatureActivity_Master na ON csr.NA_ID=na.NA_ID
where csr.FB_ID=@ID and csr.premisesAddress=@premisesAddress and csr.CS_ID=@CSID and csr.deleted=0

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[UFN_GetCurrentQuarter]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UFN_GetCurrentQuarter]
()
RETURNS int
AS
BEGIN
	declare @quarter nvarchar(20)
	declare @qtrId int
	select @quarter='Q'+CAST(DatePart(Quarter,GETDATE()) as nvarchar)+' '+CAST(DATEPART(YEAR,GETDATE()) as nvarchar)

	select @qtrId=Qtr_ID from Quater_Master where LEFT(Qtr_Name,7)=@quarter

	return @qtrId
END
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetDetailsByApplicantName]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetDetailsByApplicantName]
(
	@matchcol varchar(200)
)
returns varchar(2000)

as
begin
Declare @retval varchar(2000)
select @retval=COALESCE(@retval+', ','')+ userId from ncb_LoginMaster where applicantName=@matchcol and status=1 and deleted=0

return @retval
end

GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetLActivityByName1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetLActivityByName1]
(
	@ID int,
	@CSID int,
	@premisesAddress varchar(256)
)
returns varchar(100)

as
begin
Declare @activity varchar(1000)
select @activity=COALESCE(@activity+'<br/>','')+na.NatureActivity+CASE WHEN OthersNA is NOT null OR OthersNA<>'' THEN '-'+OthersNA ELSE '' END
from ControlledSubstanceReg_Log csr inner join NatureActivity_Master na ON csr.NA_ID=na.NA_ID
where csr.FB_ID=@ID and csr.premisesAddress=@premisesAddress and csr.CS_ID=@CSID and csr.deleted=0

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetNatureActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetNatureActivity]
(
	@valueType varchar(50),
	@FB_ID int,
	@CS_ID int
)
returns varchar(2000)

as
begin
Declare @activity varchar(2000)
if(@valueType = 'Activity')
select @activity=COALESCE(@activity+', ','')+ nm.NatureActivity from fb_ControlledSubstanceReg csReg inner join NatureActivity_Master nm on 
csReg.NA_ID = nm.NA_ID where csReg.FB_ID = @FB_ID and csReg.CS_ID  = @CS_ID and csReg.deleted = 0  
group by FB_ID, CS_ID, nm.NA_ID, nm.NatureActivity 


return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetNatureActivity_New]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetNatureActivity_New]
(
	@valueType varchar(50),
	@FB_ID int
)
returns varchar(2000)

as
begin
Declare @activity varchar(2000)
if(@valueType = 'Activity')

select @activity=COALESCE(@activity+', ','')+ Nature from(
select REPLACE(nm.NatureActivity,'(Please Specify)','')+Case WHEN csReg.NA_ID=10 and (csReg.OthersNA is not null OR csReg.OthersNA<>'') THEN '-'+csReg.OthersNA else '' end Nature
from fb_ControlledSubstanceReg csReg(NOLOCK) inner join NatureActivity_Master(NOLOCK) nm on 
csReg.NA_ID = nm.NA_ID where csReg.FB_ID = @FB_ID and csReg.deleted = 0  
group by FB_ID, CS_ID, nm.NA_ID, nm.NatureActivity,csReg.OthersNA,csReg.NA_ID
)dd group by Nature

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetNatureActivityExport]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetNatureActivityExport]
(
	
	@FB_ID int
)
returns varchar(2000)

as
begin
Declare @activity varchar(2000)

select @activity=COALESCE(@activity+', ','')+ nm.NatureActivity from fb_ControlledSubstanceReg csReg inner join NatureActivity_Master nm on 
csReg.NA_ID = nm.NA_ID where csReg.FB_ID = @FB_ID and csReg.deleted = 0  
group by FB_ID, nm.NA_ID, nm.NatureActivity 


return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetNatureActivityNew]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetNatureActivityNew]
(
	@valueType varchar(50),
	@FB_ID int,
	@premiseaddress nvarchar(1000)
)
returns varchar(2000)

as
begin
Declare @activity varchar(2000)
if(@valueType = 'Activity')

select @activity=COALESCE(@activity+', ','')+ Nature from(
select REPLACE(nm.NatureActivity,'(Please Specify)','')+Case WHEN csReg.NA_ID=10 and (csReg.OthersNA is not null OR csReg.OthersNA<>'') THEN '-'+csReg.OthersNA else '' end Nature
from fb_ControlledSubstanceReg csReg(NOLOCK) inner join NatureActivity_Master(NOLOCK) nm on 
csReg.NA_ID = nm.NA_ID where csReg.FB_ID = @FB_ID and csReg.premisesAddress  = @premiseaddress and csReg.deleted = 0  
group by FB_ID, CS_ID, nm.NA_ID, nm.NatureActivity,csReg.OthersNA,csReg.NA_ID
)dd group by Nature

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[UFN_GetOpeningBalance]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UFN_GetOpeningBalance]
(
	@Quater int,
	@URN nvarchar(50),
	@SubURN nvarchar(50)=''
)
returns decimal(18,2)
as
BEGIN
	--declare @totalreceipt decimal(18,2)
	--declare @totalsale decimal(18,2)
	--declare @totalconsumtion decimal(18,2)
	--declare @openingBalance decimal(18,2)
	declare @closingBalance decimal(18,2)
	--select TOP 1 @openingBalance=C.CL_Balance FROM tn_FormF F INNER JOIN ff_Receipt_Import C ON F.FF_Id=C.FF_ID where F.Quater=@Quater-1 and F.URN=@URN and (F.subURN=@SubURN or @SubURN='') order by F.FF_ID DESC
	
	--select @totalreceipt=SUM(CASE WHEN C.Category=1 THEN Quantity_Received else 0 end),@totalsale=SUM(CASE WHEN C.Category=2 THEN Quantity_Received else 0 end),
	--		@totalconsumtion=SUM(CASE WHEN C.Category=3 THEN Quantity_Received else 0 end)  
	
	--from tn_FormF F INNER JOIN ff_Receipt_Import C ON F.FF_Id=C.FF_ID where F.Quater=@Quater and F.URN=@URN

	--SET @closingBalance=(@openingBalance+@totalreceipt)-(@totalsale+@totalconsumtion)
	select @closingBalance=(CASE WHEN closingBalance is null THEN (SELECT TOP 1 OP_Balance+SUM(Quantity_Received) from ff_Receipt_Import where FF_ID=F.FF_ID and deleted=0 and Category=1 and Quater=@Quater-1 group by OP_Balance)-(SELECT SUM(Quantity_Received) from ff_Receipt_Import where FF_ID=F.FF_ID and Quater=@Quater-1 and Category in (2,3)) else closingBalance end) FROM tn_FormF F where F.Quater=@Quater-1 and F.URN=@URN and (F.subURN=@SubURN or @SubURN='') order by F.FF_ID DESC
	return @closingBalance
END
GO
/****** Object:  UserDefinedFunction [dbo].[UFN_GetPreviousQuarter]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UFN_GetPreviousQuarter]
()
RETURNS int
AS
BEGIN
	declare @quarter nvarchar(20)
	declare @qtrId int
	select @quarter='Q'+CAST(DatePart(Quarter,GETDATE()-20) as nvarchar)+' '+CAST(DATEPART(YEAR,GETDATE()) as nvarchar)

	select @qtrId=Qtr_ID from Quater_Master where LEFT(Qtr_Name,7)=@quarter

	return @qtrId-1
END
GO
/****** Object:  UserDefinedFunction [dbo].[UFN_GetQuarterId]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[UFN_GetQuarterId]
(
	@ReturnDate datetime
)

returns int
as
begin
declare @Id int

select @Id=Qtr_Id from Quater_Master where Qtr_ID > 0 and 

rtrim(ltrim(LEFT(Qtr_Name,CHARINDEX('-',Qtr_Name)-1)))='Q'+cast(datepart(qq,@ReturnDate) as nvarchar)+' '+cast(datepart(year,@ReturnDate) as nvarchar)

return @Id
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetSubActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ufn_GetSubActivity]
(
	@ID int,
	@Address varchar(256),
	@CS_ID int
)
returns varchar(100)

as
begin
Declare @activity varchar(100)
select @activity=COALESCE(@activity+',','')+CAST(S_NA_ID as varchar) from fb_ControlledSubstance_SubNatureActivity 
where FB_ID=@ID and premisesAddress=@Address and CS_ID=@CS_ID and Deleted=0

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetSubActivityByName]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ufn_GetSubActivityByName]
(
	@ID int,
	@CSID int,
	@premisesAddress varchar(256)
)
returns varchar(100)

as
begin
Declare @activity varchar(1000)
select @activity=COALESCE(@activity+'<br/>','')+REPLACE(na.SubActivity,'(Please Specify)','')+CAsE WHEN na.SubActivity='Other(Please Specify)' THEN '-'+Others else '' END 
from fb_ControlledSubstance_SubNatureActivity csr inner join Sub_NatureActivity_Master na ON csr.S_NA_ID=na.S_NA_ID
where csr.FB_ID=@ID and csr.premisesAddress=@premisesAddress and csr.CS_ID=@CSID and csr.deleted=0

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetSubstance]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetSubstance]
(
	@FB_ID int
)
returns varchar(2000)

as
begin
Declare @activity varchar(2000)

select @activity=COALESCE(@activity+', ','')+ nm.ControlledSubstance from fb_ControlledSubstanceReg csReg 
inner join ControlledSubstance_Master nm on 
csReg.CS_ID = nm.CS_ID where csReg.FB_ID = @FB_ID and csReg.deleted = 0  group by ControlledSubstance
return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetSubstancesWithURNandQuarter]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ufn_GetSubstancesWithURNandQuarter]
(
	@urn varchar(50),
	@valueType varchar(50),
	@category int,
	@Quarter int
)
returns varchar(2000)

as
begin
Declare @substance varchar(3000)

if(@valueType = 'Lavel2Substance')
select @substance=COALESCE(@substance+'<br/>','')+ sub.ControlledSubstance from VW_SubstanceQtyWithURNandQuarter sub  where URN = @urn and 
Quater = @Quarter group by sub.ControlledSubstance, sub.Quater, sub.URN order by sub.ControlledSubstance

else if(@valueType = 'Lavel2Quantity')
begin
	declare @table as table
	(
		Qty decimal(18, 2)
	) 
	insert into @table(Qty)
	select isnull((select SUM(qty.RecQty) from VW_SubstanceQtyWithURNandQuarter qty where qty.ControlledSubstance = 
	sub.ControlledSubstance and qty.Quater = sub.Quater and qty.URN = sub.URN and qty.Category = @category), 0)as RecQty
	from VW_SubstanceQtyWithURNandQuarter sub  where URN = @urn and Quater = @Quarter
	group by sub.ControlledSubstance, sub.Quater, sub.URN order by sub.ControlledSubstance

	select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, Qty)  from @table

end

    --  ---------Form E Substances and Qty ---------------------------

else if(@valueType = 'Lavel2FormESubstance')
select @substance=COALESCE(@substance+'<br/>','')+ ControlledSubstance from VW_SubstanceFormE where urnNo = @urn and returnQuarter = @Quarter
group by ControlledSubstance

else if(@valueType = 'Lavel2FormESoldQty')
begin
	declare @table1 as table
	(
		Qty decimal(18, 2)
	) 
	insert into @table1(Qty)
	
	select isnull((select sum(sold.soldQty) from VW_SalesSubtanceWithUrnAndQuarter sold where sold.urnNo = sub.urnNo and 
	sold.returnQuarter = sub.returnQuarter and sold.ControlledSubstance =  sub.ControlledSubstance), 0)as soldQty
	from VW_SubstanceFormE sub where sub.urnNo = @urn and sub.returnQuarter = @Quarter
	order by sub.ControlledSubstance
	
	--select ISNULL( SUM(sold.soldQty), 0)as soldQty  from VW_SubstanceFormE sub left join VW_SalesSubtanceWithUrnAndQuarter sold 
	--on sub.ControlledSubstance = sold.ControlledSubstance and sub.returnQuarter = sold.returnQuarter
	--where sub.urnNo = @urn and sub.returnQuarter = @Quarter and sold.urnNo = @urn and sold.returnQuarter = @Quarter
	--group by sub.ControlledSubstance

	select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, Qty)  from @table1

end

else if(@valueType = 'Lavel2FormEMFDQty')
begin
	declare @table2 as table
	(
		Qty decimal(18, 2)
	) 
	insert into @table2(Qty)
	
	select isnull((select sum(mfd.mfdQty) from VW_MFDWithUrnAndQuarter mfd where mfd.urnNo = sub.urnNo and 
	mfd.returnQuarter = sub.returnQuarter and mfd.ControlledSubstance =  sub.ControlledSubstance), 0)as mfdQty
	from VW_SubstanceFormE sub where sub.urnNo = @urn and sub.returnQuarter = @Quarter
	order by sub.ControlledSubstance
	
	--select ISNULL( SUM(mfd.mfdQty), 0)as mfdQty  from VW_SubstanceFormE sub left join VW_MFDWithUrnAndQuarter mfd 
	--on sub.ControlledSubstance = mfd.ControlledSubstance and sub.returnQuarter = mfd.returnQuarter
	--where sub.urnNo = @urn and sub.returnQuarter = @Quarter and mfd.urnNo = @urn and mfd.returnQuarter = @Quarter
	--group by sub.ControlledSubstance

	select @substance=COALESCE(@substance+'<br/>','')+ CONVERT(varchar, Qty)  from @table2

end

return @substance
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetSubSubActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ufn_GetSubSubActivity]
(
	@ID int,
	@Address varchar(256),
	@CS_ID int
)
returns varchar(100)

as
begin
Declare @activity varchar(100)
select @activity=COALESCE(@activity+',','')+CAST(SS_NA_ID as varchar) from fb_ControlledSubstance_SubSubNatureActivity 
where FB_ID=@ID and premisesAddress=@Address and CS_ID=@CS_ID  and Deleted=0

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetSubSubActivityByName]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ufn_GetSubSubActivityByName]
(
	@ID int,
	@CSID int,
	@premisesAddress varchar(256)
)
returns varchar(100)

as
begin
Declare @activity varchar(1000)
select @activity=COALESCE(@activity+'<br/>','')+na.SubSubActivity 
from fb_ControlledSubstance_SubSubNatureActivity csr inner join SubSub_NatureActivity_Master na ON csr.SS_NA_ID=na.SS_NA_ID
where csr.FB_ID=@ID and csr.premisesAddress=@premisesAddress and csr.CS_ID=@CSID and csr.deleted=0

return @activity
end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_MaserDataName]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[ufn_MaserDataName]
(
	@ID int
)
returns varchar(2000)

as
begin
Declare @substance varchar(2000)
select @substance=COALESCE(@substance+'<br/>','')+cs.ControlledSubstance from fb_ControlledSubstanceReg csr inner join ControlledSubstance_Master cs ON csr.CS_ID=cs.CS_ID 
where FB_ID=@ID

return @substance
end
GO
/****** Object:  Table [dbo].[Quater_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Quater_Master](
	[Qtr_ID] [int] IDENTITY(-1,1) NOT NULL,
	[Qtr_Name] [nvarchar](50) NULL,
	[Qtr_Desc] [nvarchar](100) NULL,
	[Qtr_EndDate] [datetime] NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_Quater_Master] PRIMARY KEY CLUSTERED 
(
	[Qtr_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ControlledSubstance_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ControlledSubstance_Master](
	[CS_ID] [int] IDENTITY(1,1) NOT NULL,
	[ControlledSubstance] [nvarchar](100) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_SectorMaster] PRIMARY KEY CLUSTERED 
(
	[CS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormB]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormB](
	[FB_ID] [int] IDENTITY(1,1) NOT NULL,
	[applicantName] [varchar](128) NULL,
	[ZO_ID] [int] NULL,
	[regAnotherZone1] [varchar](128) NULL,
	[regAnotherZone2] [varchar](128) NULL,
	[earlierSurrendered] [varchar](128) NULL,
	[applicantAddress] [varchar](256) NULL,
	[cityName] [varchar](64) NULL,
	[pincode] [varchar](8) NULL,
	[S_ID] [int] NULL,
	[mobileNo] [varchar](16) NULL,
	[telephoneNo] [varchar](16) NULL,
	[faxNo] [varchar](16) NULL,
	[emailId] [varchar](64) NULL,
	[panNo] [varchar](16) NULL,
	[applicantName_Pan] [varchar](128) NULL,
	[panApplied] [varchar](3) NULL,
	[panApplyProof] [varchar](128) NULL,
	[businessConstitution] [varchar](32) NULL,
	[conviction_PendingCases] [varchar](256) NULL,
	[orderDetails] [varchar](256) NULL,
	[declarationName] [varchar](128) NULL,
	[declareDate] [datetime] NULL,
	[declarePlace] [varchar](64) NULL,
	[signature] [varchar](128) NULL,
	[authorizationLetter] [varchar](3) NULL,
	[authorizationLetterDoc] [varchar](128) NULL,
	[signingPersonPan] [varchar](3) NULL,
	[signingPersonPanDoc] [varchar](128) NULL,
	[applicantPan] [varchar](3) NULL,
	[applicantPanDoc] [varchar](128) NULL,
	[certificateIncorporation] [varchar](3) NULL,
	[certificateIncorporationDoc] [varchar](128) NULL,
	[ownershipProof] [varchar](3) NULL,
	[ownershipProofDoc] [varchar](128) NULL,
	[drugLicence] [varchar](3) NULL,
	[drugLicenceDoc] [varchar](128) NULL,
	[importExportCode] [varchar](3) NULL,
	[importExportCodeDoc] [varchar](128) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[isSubmitted] [tinyint] NULL,
	[tempRegNo] [varchar](16) NULL,
	[userRegNo] [varchar](16) NULL,
	[userRegNo_IssueDT] [datetime] NULL,
	[fb_HardCopy_Rcv] [char](3) NULL,
	[fb_Approval_Status] [char](3) NULL,
	[fb_Approval_By] [int] NULL,
	[fa_Generate_Status] [char](3) NULL,
	[fa_Generate_By] [int] NULL,
	[stepComplete] [int] NULL,
	[tempRegNo_Date] [datetime] NULL,
	[fb_HardCopy_Rcv_Date] [datetime] NULL,
	[fa_Generate_Date] [datetime] NULL,
	[fb_Approval_Date] [datetime] NULL,
	[hcRecieved_By] [int] NULL,
	[IsBlocked] [bit] NULL,
	[blockedDate] [datetime] NULL,
	[blockedBy] [int] NULL,
	[IsReassigned] [tinyint] NULL,
 CONSTRAINT [PK_tn_FormB] PRIMARY KEY CLUSTERED 
(
	[FB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fe_SaleDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fe_SaleDetails](
	[SD_ID] [int] IDENTITY(1,1) NOT NULL,
	[FED_ID] [int] NULL,
	[saleDate] [datetime] NULL,
	[urnNo] [varchar](16) NULL,
	[nocNo] [varchar](16) NULL,
	[personName] [varchar](128) NULL,
	[personAddress] [varchar](256) NULL,
	[consignNo] [varchar](16) NULL,
	[consignDate] [datetime] NULL,
	[consignQTY] [decimal](18, 2) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fe_SaleDetails] PRIMARY KEY CLUSTERED 
(
	[SD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fe_SubStanceDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fe_SubStanceDetails](
	[FED_ID] [int] IDENTITY(1,1) NOT NULL,
	[FE_ID] [int] NULL,
	[CS_ID] [int] NULL,
	[openingBalance] [decimal](18, 2) NULL,
	[closingBalance] [decimal](18, 2) NULL,
	[totalManufacture] [decimal](18, 2) NULL,
	[totalSale] [decimal](18, 2) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fe_SubStanceDetails] PRIMARY KEY CLUSTERED 
(
	[FED_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormE]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormE](
	[FE_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[returnQuarter] [int] NULL,
	[urnNo] [varchar](16) NULL,
	[manufacturerName] [varchar](128) NULL,
	[address] [varchar](256) NULL,
	[S_ID] [int] NULL,
	[city] [varchar](64) NULL,
	[pincode] [varchar](8) NULL,
	[returnFilled] [varchar](4) NULL,
	[reasonDelaySubmission] [varchar](256) NULL,
	[name] [varchar](64) NULL,
	[designation] [varchar](128) NULL,
	[declarationDate] [datetime] NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_tn_FormE] PRIMARY KEY CLUSTERED 
(
	[FE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Temp1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Temp1]
AS
SELECT     dbo.tn_FormE.urnNo AS URN1, dbo.fe_SaleDetails.urnNo AS URN2, SUM(dbo.fe_SaleDetails.consignQTY) AS saleQTY, 
                      ControlledSubstance_Master_1.ControlledSubstance, dbo.tn_FormE.manufacturerName, dbo.Quater_Master.Qtr_Name, dbo.tn_FormE.FB_ID AS SellerFB_ID, 
                      dbo.tn_FormB.applicantName AS Buyer_Name, tn_FormB_1.ZO_ID AS SellerZone1, dbo.tn_FormB.ZO_ID AS SellerZone2, dbo.tn_FormB.FB_ID AS SellerFB_ID2, 
                      dbo.Quater_Master.Qtr_ID
FROM         dbo.tn_FormE INNER JOIN
                      dbo.fe_SubStanceDetails ON dbo.tn_FormE.FE_ID = dbo.fe_SubStanceDetails.FE_ID INNER JOIN
                      dbo.fe_SaleDetails ON dbo.fe_SubStanceDetails.FED_ID = dbo.fe_SaleDetails.FED_ID INNER JOIN
                      dbo.ControlledSubstance_Master AS ControlledSubstance_Master_1 ON dbo.fe_SubStanceDetails.CS_ID = ControlledSubstance_Master_1.CS_ID INNER JOIN
                      dbo.Quater_Master ON dbo.tn_FormE.returnQuarter = dbo.Quater_Master.Qtr_ID INNER JOIN
                      dbo.tn_FormB ON dbo.fe_SaleDetails.urnNo = dbo.tn_FormB.userRegNo INNER JOIN
                      dbo.tn_FormB AS tn_FormB_1 ON dbo.tn_FormE.FB_ID = tn_FormB_1.FB_ID
WHERE     (dbo.fe_SaleDetails.urnNo <> 'ES000000000') AND (dbo.tn_FormE.deleted = 0) AND (dbo.fe_SaleDetails.deleted = 0)
GROUP BY dbo.tn_FormE.urnNo, dbo.fe_SaleDetails.urnNo, ControlledSubstance_Master_1.ControlledSubstance, dbo.tn_FormE.manufacturerName, 
                      dbo.Quater_Master.Qtr_Name, dbo.tn_FormE.FB_ID, dbo.tn_FormB.applicantName, tn_FormB_1.ZO_ID, dbo.tn_FormB.ZO_ID, dbo.tn_FormB.FB_ID, 
                      dbo.Quater_Master.Qtr_ID
GO
/****** Object:  Table [dbo].[ff_Receipt_Import]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ff_Receipt_Import](
	[FD_ID] [int] IDENTITY(1,1) NOT NULL,
	[FF_ID] [int] NOT NULL,
	[loginID] [int] NOT NULL,
	[CS_ID] [int] NULL,
	[OP_Balance] [decimal](18, 6) NULL,
	[OP_Date] [date] NULL,
	[URN] [nvarchar](50) NULL,
	[nocNo] [nvarchar](50) NULL,
	[Reciever] [nvarchar](100) NULL,
	[Reciever_Add] [nvarchar](500) NULL,
	[Consignment] [nvarchar](50) NULL,
	[Quantity_Received] [decimal](18, 6) NULL,
	[Total] [decimal](18, 6) NULL,
	[CL_Balance] [decimal](18, 6) NULL,
	[Category] [int] NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_ff_Receipt_Import] PRIMARY KEY CLUSTERED 
(
	[FD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormF]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormF](
	[FF_ID] [int] IDENTITY(1,1) NOT NULL,
	[loginID] [int] NULL,
	[Quater] [int] NULL,
	[URN] [nvarchar](50) NULL,
	[Seller_Name] [nvarchar](50) NULL,
	[Address] [nvarchar](200) NULL,
	[State_ID] [int] NULL,
	[City_Name] [nvarchar](50) NULL,
	[Pincode] [nvarchar](6) NULL,
	[Details_Type] [int] NULL,
	[ISWithinDueDT] [char](3) NULL,
	[Signature] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Designation] [nvarchar](50) NULL,
	[Sign_DT] [date] NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[subURN] [nvarchar](50) NULL,
	[closingBalance] [decimal](18, 2) NULL,
	[CS1] [decimal](18, 6) NULL,
	[CS2] [decimal](18, 6) NULL,
	[CS3] [decimal](18, 6) NULL,
	[CS4] [decimal](18, 6) NULL,
	[CS5] [decimal](18, 6) NULL,
	[CS6] [decimal](18, 6) NULL,
	[CS7] [decimal](18, 6) NULL,
	[CS8] [decimal](18, 6) NULL,
	[CS9] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_ControlledSubstanceReg]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_ControlledSubstanceReg](
	[PD_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[premisesAddress] [varchar](256) NULL,
	[PT_ID] [int] NULL,
	[otherPremises] [varchar](32) NULL,
	[ON_ID] [int] NULL,
	[otherOccupationNature] [varchar](32) NULL,
	[commissionate] [varchar](64) NULL,
	[division] [varchar](64) NULL,
	[range] [varchar](32) NULL,
	[address] [varchar](256) NULL,
	[contactDetails] [varchar](32) NULL,
	[CS_ID] [int] NULL,
	[NA_ID] [int] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[S_ID] [int] NULL,
	[D_ID] [int] NULL,
	[C_ID] [int] NULL,
	[pinCode] [varchar](8) NULL,
	[OthersNA] [nvarchar](64) NULL,
 CONSTRAINT [PK_fb_ControlledSubstanceReg] PRIMARY KEY CLUSTERED 
(
	[PD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Temp2]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Temp2]
AS
SELECT     dbo.tn_FormF.URN AS URN1, dbo.ff_Receipt_Import.URN AS URN2, dbo.ControlledSubstance_Master.ControlledSubstance, 
                      SUM(dbo.ff_Receipt_Import.Quantity_Received) AS PurchaseQTY, dbo.Quater_Master.Qtr_Name, dbo.tn_FormF.Seller_Name AS Buyer_Name, 
                      dbo.tn_FormB.applicantName AS Seller_Name, tn_FormB_1.FB_ID, tn_FormB_1.ZO_ID AS BuyerZone1, dbo.tn_FormB.ZO_ID AS BuyerZone2, 
                      dbo.tn_FormB.FB_ID AS FB_ID2, dbo.Quater_Master.Qtr_ID
FROM         dbo.fb_ControlledSubstanceReg INNER JOIN
                      dbo.tn_FormB ON dbo.fb_ControlledSubstanceReg.FB_ID = dbo.tn_FormB.FB_ID INNER JOIN
                      dbo.ControlledSubstance_Master INNER JOIN
                      dbo.ff_Receipt_Import ON dbo.ControlledSubstance_Master.CS_ID = dbo.ff_Receipt_Import.CS_ID INNER JOIN
                      dbo.tn_FormF ON dbo.ff_Receipt_Import.FF_ID = dbo.tn_FormF.FF_ID INNER JOIN
                      dbo.Quater_Master ON dbo.tn_FormF.Quater = dbo.Quater_Master.Qtr_ID ON dbo.tn_FormB.userRegNo = dbo.ff_Receipt_Import.URN INNER JOIN
                      dbo.tn_FormB AS tn_FormB_1 ON dbo.tn_FormF.loginID = tn_FormB_1.addBy
WHERE     (dbo.ff_Receipt_Import.URN <> 'IMP00000000') AND (dbo.ff_Receipt_Import.Category = 1) AND (dbo.ff_Receipt_Import.Deleted = 0) AND (dbo.tn_FormF.deleted = 0) AND
                       (dbo.fb_ControlledSubstanceReg.NA_ID IN (1))
GROUP BY dbo.tn_FormF.URN, dbo.ff_Receipt_Import.URN, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.ff_Receipt_Import.Category, 
                      dbo.Quater_Master.Qtr_Name, dbo.tn_FormF.Seller_Name, dbo.tn_FormB.applicantName, tn_FormB_1.FB_ID, tn_FormB_1.ZO_ID, dbo.tn_FormB.ZO_ID, 
                      dbo.tn_FormB.FB_ID, dbo.Quater_Master.Qtr_ID

GO
/****** Object:  View [dbo].[UV_FormE_F_ComparativeReport]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_FormE_F_ComparativeReport]
AS
SELECT        dbo.Temp1.URN1 AS soldURN1, dbo.Temp1.URN2 AS soldURN2, SUM(DISTINCT ISNULL(dbo.Temp1.saleQTY, 0)) AS saleQTY, dbo.Temp1.ControlledSubstance, 
                         dbo.Temp2.URN1 AS purchaseURN1, dbo.Temp2.URN2 AS purchaseURN2, dbo.Temp2.ControlledSubstance AS ControlledSubstance2, 
                         SUM(DISTINCT ISNULL(dbo.Temp2.PurchaseQTY, 0)) AS PurchaseQTY, SUM(DISTINCT ISNULL(dbo.Temp1.saleQTY, 0) - ISNULL(dbo.Temp2.PurchaseQTY, 0)) 
                         AS Difference, dbo.Temp2.Seller_Name, dbo.Temp1.manufacturerName, 
                         (CASE WHEN dbo.Temp1.URN1 <> '' THEN 'rptQuarterFormE.aspx?urn=' + dbo.Temp1.URN1 + '&&urn2=' + dbo.Temp1.URN2 + '&&cs=' + dbo.Temp1.ControlledSubstance
                          + '&&align=left' ELSE 'javascript:void(0);' END) AS URL, 
                         (CASE WHEN dbo.Temp2.URN1 <> '' THEN 'rptQuarterFormE.aspx?urn=' + dbo.Temp2.URN1 + '&&urn2=' + dbo.Temp2.URN2 + '&&cs=' + dbo.Temp2.ControlledSubstance
                          + '&&align=reight' ELSE 'javascript:void(0);' END) AS URL2, dbo.Temp1.SellerFB_ID, dbo.Temp2.Buyer_Name AS Buyer_Name2, 
                         dbo.Temp1.Buyer_Name AS Buyer_Name1, dbo.Temp2.FB_ID AS BuyerFB_ID, dbo.Temp1.SellerZone1, dbo.Temp1.SellerZone2, dbo.Temp2.BuyerZone1, 
                         dbo.Temp2.BuyerZone2, dbo.Temp1.SellerFB_ID2, dbo.Temp2.FB_ID2 AS BuyerFB_ID2, dbo.Temp2.Qtr_ID AS BuyerQtrID, dbo.Temp1.Qtr_ID AS SellerQtrID
FROM            dbo.Temp1 FULL OUTER JOIN
                         dbo.Temp2 ON dbo.Temp1.URN2 = dbo.Temp2.URN1 AND dbo.Temp1.URN1 = dbo.Temp2.URN2 AND 
                         dbo.Temp1.ControlledSubstance = dbo.Temp2.ControlledSubstance
WHERE        (ISNULL(dbo.Temp1.saleQTY, 0) - ISNULL(dbo.Temp2.PurchaseQTY, 0) <> 0)
GROUP BY dbo.Temp1.URN1, dbo.Temp1.URN2, dbo.Temp1.ControlledSubstance, dbo.Temp2.URN1, dbo.Temp2.URN2, dbo.Temp2.ControlledSubstance, 
                         dbo.Temp2.Seller_Name, dbo.Temp1.manufacturerName, dbo.Temp1.SellerFB_ID, dbo.Temp2.Buyer_Name, dbo.Temp1.Buyer_Name, dbo.Temp2.FB_ID, 
                         dbo.Temp1.SellerZone1, dbo.Temp1.SellerZone2, dbo.Temp2.BuyerZone1, dbo.Temp2.BuyerZone2, dbo.Temp1.SellerFB_ID2, dbo.Temp2.FB_ID2, 
                         dbo.Temp2.Qtr_ID, dbo.Temp1.Qtr_ID
GO
/****** Object:  Table [dbo].[fh_consignments_details]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fh_consignments_details](
	[HD_ID] [int] IDENTITY(1,1) NOT NULL,
	[FH_ID] [int] NOT NULL,
	[loginID] [int] NOT NULL,
	[CS_ID] [int] NULL,
	[Sent_Date] [date] NULL,
	[URN] [nvarchar](50) NULL,
	[Quantity] [decimal](18, 2) NULL,
	[Name] [nvarchar](500) NULL,
	[Sent_Address] [nvarchar](50) NULL,
	[ConsignmentNo] [nvarchar](50) NULL,
	[Transport_Mode] [nvarchar](50) NULL,
	[transportNo] [nvarchar](50) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_fh_Receipt_Import] PRIMARY KEY CLUSTERED 
(
	[HD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormH]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormH](
	[FH_ID] [int] IDENTITY(1,1) NOT NULL,
	[loginID] [int] NULL,
	[Quater] [int] NULL,
	[URN] [nvarchar](50) NULL,
	[consignor_Name] [nvarchar](50) NULL,
	[Address] [nvarchar](200) NULL,
	[Signature] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Designation] [nvarchar](50) NULL,
	[Sign_DT] [date] NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Temp5]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Temp5]
AS
SELECT     dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormH.URN AS URN1, dbo.fh_consignments_details.URN AS URN2, 
                      SUM(dbo.fh_consignments_details.Quantity) AS soldQTY
FROM         dbo.ControlledSubstance_Master INNER JOIN
                      dbo.fh_consignments_details ON dbo.ControlledSubstance_Master.CS_ID = dbo.fh_consignments_details.CS_ID INNER JOIN
                      dbo.tn_FormH ON dbo.fh_consignments_details.FH_ID = dbo.tn_FormH.FH_ID
WHERE     (dbo.tn_FormH.deleted = 0) AND (dbo.fh_consignments_details.Deleted = 0)
GROUP BY dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormH.URN, dbo.fh_consignments_details.URN
GO
/****** Object:  View [dbo].[UV_ComparativeReport_H2F]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_ComparativeReport_H2F]
AS
SELECT     dbo.Temp5.ControlledSubstance, dbo.Temp5.URN1 + '/' + dbo.Temp5.URN2 AS soldURN, ISNULL(dbo.Temp5.soldQTY, 0) AS soldQTY, 
                      ISNULL(dbo.Temp2.PurchaseQTY, 0) AS PurchaseQTY, dbo.Temp2.ControlledSubstance AS ControlledSubstance2, 
                      dbo.Temp2.URN1 + '/' + dbo.Temp2.URN2 AS purchaseURN, ISNULL(dbo.Temp5.soldQTY, 0) - ISNULL(dbo.Temp2.PurchaseQTY, 0) AS Difference
FROM         dbo.Temp2 FULL OUTER JOIN
                      dbo.Temp5 ON dbo.Temp2.ControlledSubstance = dbo.Temp5.ControlledSubstance AND dbo.Temp2.URN2 = dbo.Temp5.URN1 AND 
                      dbo.Temp2.URN1 = dbo.Temp5.URN2
GO
/****** Object:  View [dbo].[UV_ComparativeReportQuarterFormE]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[UV_ComparativeReportQuarterFormE]
AS
SELECT     dbo.Temp1.URN1 AS soldURN1, dbo.Temp1.URN2 AS soldURN2, ISNULL(dbo.Temp1.saleQTY, 0) AS saleQTY, dbo.Temp1.ControlledSubstance, 
                      dbo.Temp2.URN1 AS purchaseURN1, dbo.Temp2.URN2 AS purchaseURN2, dbo.Temp2.ControlledSubstance AS ControlledSubstance2, 
                      ISNULL(dbo.Temp2.PurchaseQTY, 0) AS PurchaseQTY, ISNULL(dbo.Temp1.saleQTY, 0) - ISNULL(dbo.Temp2.PurchaseQTY, 0) AS Difference, dbo.Temp2.Seller_Name, 
                      dbo.Temp2.Qtr_Name AS QTR2, dbo.Temp1.Qtr_Name AS QTR1, dbo.Temp1.manufacturerName, dbo.Temp1.SellerFB_ID, dbo.Temp2.FB_ID AS BuyerFB_ID, 
                      dbo.Temp1.Buyer_Name AS Buyer_Name1, dbo.Temp2.Buyer_Name AS Buyer_Name2, dbo.Temp1.SellerZone1, dbo.Temp1.SellerZone2, dbo.Temp2.BuyerZone1, 
                      dbo.Temp2.BuyerZone2, dbo.Temp2.FB_ID2 AS BuyerFB_ID2, dbo.Temp1.SellerFB_ID2, dbo.Temp1.Qtr_ID AS Qtr_ID1, dbo.Temp2.Qtr_ID AS Qtr_ID2
FROM         dbo.Temp2 FULL OUTER JOIN
                      dbo.Temp1 ON dbo.Temp2.Qtr_Name = dbo.Temp1.Qtr_Name AND dbo.Temp2.URN1 = dbo.Temp1.URN2 AND dbo.Temp2.URN2 = dbo.Temp1.URN1 AND 
                      dbo.Temp2.ControlledSubstance = dbo.Temp1.ControlledSubstance
GROUP BY dbo.Temp1.URN1, dbo.Temp1.URN2, ISNULL(dbo.Temp1.saleQTY, 0), dbo.Temp1.ControlledSubstance, dbo.Temp2.URN1, dbo.Temp2.URN2, 
                      dbo.Temp2.ControlledSubstance, ISNULL(dbo.Temp2.PurchaseQTY, 0), ISNULL(dbo.Temp1.saleQTY, 0) - ISNULL(dbo.Temp2.PurchaseQTY, 0), 
                      dbo.Temp2.Seller_Name, dbo.Temp1.manufacturerName, dbo.Temp2.Qtr_Name, dbo.Temp1.Qtr_Name, dbo.Temp1.SellerFB_ID, dbo.Temp2.FB_ID, 
                      dbo.Temp1.Buyer_Name, dbo.Temp2.Buyer_Name, dbo.Temp1.SellerZone1, dbo.Temp1.SellerZone2, dbo.Temp2.BuyerZone1, dbo.Temp2.BuyerZone2, 
                      dbo.Temp2.FB_ID2, dbo.Temp1.SellerFB_ID2, dbo.Temp1.Qtr_ID, dbo.Temp2.Qtr_ID
HAVING      (ISNULL(dbo.Temp1.saleQTY, 0) - ISNULL(dbo.Temp2.PurchaseQTY, 0) <> 0)

GO
/****** Object:  View [dbo].[Temp3]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Temp3]
AS
SELECT     dbo.tn_FormF.URN AS URN1, dbo.ff_Receipt_Import.URN AS URN2, dbo.ControlledSubstance_Master.ControlledSubstance, 
                      SUM(dbo.ff_Receipt_Import.Quantity_Received) AS soldQTY, dbo.Quater_Master.Qtr_Name, dbo.tn_FormF.Seller_Name, dbo.tn_FormB.FB_ID AS SellerFB_ID, 
                      dbo.tn_FormB.ZO_ID AS SellerZone1, tn_FormB_1.applicantName AS Buyer_Name, tn_FormB_1.ZO_ID AS SellerZone2, tn_FormB_1.FB_ID AS SellerFB_ID2, 
                      dbo.Quater_Master.Qtr_ID
FROM         dbo.ControlledSubstance_Master INNER JOIN
                      dbo.ff_Receipt_Import ON dbo.ControlledSubstance_Master.CS_ID = dbo.ff_Receipt_Import.CS_ID INNER JOIN
                      dbo.tn_FormF ON dbo.ff_Receipt_Import.FF_ID = dbo.tn_FormF.FF_ID INNER JOIN
                      dbo.Quater_Master ON dbo.tn_FormF.Quater = dbo.Quater_Master.Qtr_ID INNER JOIN
                      dbo.tn_FormB ON dbo.tn_FormF.URN = dbo.tn_FormB.userRegNo INNER JOIN
                      dbo.tn_FormB AS tn_FormB_1 ON dbo.ff_Receipt_Import.URN = tn_FormB_1.userRegNo
WHERE     (dbo.ff_Receipt_Import.Category = 2) AND (dbo.ff_Receipt_Import.URN <> 'EXP00000000') AND (dbo.ff_Receipt_Import.Deleted = 0) AND (dbo.tn_FormF.deleted = 0)
GROUP BY dbo.tn_FormF.URN, dbo.ff_Receipt_Import.URN, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.Quater_Master.Qtr_Name, dbo.tn_FormF.Seller_Name, 
                      dbo.tn_FormB.FB_ID, dbo.tn_FormB.ZO_ID, tn_FormB_1.applicantName, tn_FormB_1.ZO_ID, tn_FormB_1.FB_ID, dbo.Quater_Master.Qtr_ID

GO
/****** Object:  View [dbo].[Temp4]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Temp4]
AS
SELECT     dbo.tn_FormF.URN AS URN1, dbo.ff_Receipt_Import.URN AS URN2, dbo.ControlledSubstance_Master.ControlledSubstance, 
                      SUM(DISTINCT dbo.ff_Receipt_Import.Quantity_Received) AS PurchaseQTY, dbo.Quater_Master.Qtr_Name, dbo.tn_FormF.Seller_Name AS BuyerName, 
                      dbo.tn_FormB.FB_ID AS BuyerFB_ID, tn_FormB_1.applicantName AS Seller_Name, dbo.tn_FormB.ZO_ID AS BuyerZone1, tn_FormB_1.ZO_ID AS BuyerZone2, 
                      tn_FormB_1.FB_ID AS BuyerFB_ID2, dbo.Quater_Master.Qtr_ID
FROM         dbo.ControlledSubstance_Master INNER JOIN
                      dbo.ff_Receipt_Import ON dbo.ControlledSubstance_Master.CS_ID = dbo.ff_Receipt_Import.CS_ID INNER JOIN
                      dbo.tn_FormF ON dbo.ff_Receipt_Import.FF_ID = dbo.tn_FormF.FF_ID INNER JOIN
                      dbo.Quater_Master ON dbo.tn_FormF.Quater = dbo.Quater_Master.Qtr_ID INNER JOIN
                      dbo.tn_FormB ON dbo.tn_FormF.URN = dbo.tn_FormB.userRegNo INNER JOIN
                      dbo.fb_ControlledSubstanceReg ON dbo.tn_FormB.FB_ID = dbo.fb_ControlledSubstanceReg.FB_ID INNER JOIN
                      dbo.tn_FormB AS tn_FormB_1 ON dbo.ff_Receipt_Import.URN = tn_FormB_1.userRegNo
WHERE     (dbo.ff_Receipt_Import.URN <> 'IMP00000000') AND (dbo.ff_Receipt_Import.Category = 1) AND (dbo.ff_Receipt_Import.Deleted = 0) AND (dbo.tn_FormF.deleted = 0) AND
                       (dbo.fb_ControlledSubstanceReg.NA_ID NOT IN (1))
GROUP BY dbo.tn_FormF.URN, dbo.ff_Receipt_Import.URN, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.ff_Receipt_Import.Category, 
                      dbo.Quater_Master.Qtr_Name, dbo.tn_FormF.Seller_Name, dbo.tn_FormB.FB_ID, tn_FormB_1.applicantName, dbo.tn_FormB.ZO_ID, tn_FormB_1.ZO_ID, 
                      tn_FormB_1.FB_ID, dbo.Quater_Master.Qtr_ID
GO
/****** Object:  View [dbo].[UV_ComparativeReportQuarterFormF]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UV_ComparativeReportQuarterFormF]
AS
SELECT     dbo.Temp3.URN1 AS soldURN1, dbo.Temp3.URN2 AS soldURN2, dbo.Temp3.ControlledSubstance, SUM(DISTINCT ISNULL(dbo.Temp3.soldQTY, 0)) AS soldQTY, 
                      ISNULL(dbo.Temp3.soldQTY, 0) - ISNULL(dbo.Temp4.PurchaseQTY, 0) AS Difference, dbo.Temp4.URN1 AS purchaseURN1, dbo.Temp4.URN2 AS purchaseURN2, 
                      SUM(DISTINCT ISNULL(dbo.Temp4.PurchaseQTY, 0)) AS PurchaseQTY, dbo.Temp4.ControlledSubstance AS ControlledSubstance2, 
                      dbo.Temp3.Seller_Name AS Seller_Name1, dbo.Temp4.BuyerName AS Buyer_Name2, dbo.Temp3.Qtr_Name AS QTR1, dbo.Temp4.Qtr_Name AS QTR2, 
                      dbo.Temp3.SellerFB_ID, dbo.Temp4.BuyerFB_ID, dbo.Temp3.Buyer_Name AS Buyer_Name1, dbo.Temp4.Seller_Name AS Seller_Name2, dbo.Temp3.SellerZone1, 
                      dbo.Temp3.SellerZone2, dbo.Temp4.BuyerZone1, dbo.Temp4.BuyerZone2, dbo.Temp4.BuyerFB_ID2, dbo.Temp3.SellerFB_ID2, dbo.Temp3.Qtr_ID AS Qtr_ID1, 
                      dbo.Temp4.Qtr_ID AS Qtr_ID2
FROM         dbo.Temp4 FULL OUTER JOIN
                      dbo.Temp3 ON dbo.Temp4.Qtr_Name = dbo.Temp3.Qtr_Name AND dbo.Temp4.URN1 = dbo.Temp3.URN2 AND dbo.Temp4.URN2 = dbo.Temp3.URN1 AND 
                      dbo.Temp4.ControlledSubstance = dbo.Temp3.ControlledSubstance
GROUP BY dbo.Temp3.ControlledSubstance, ISNULL(dbo.Temp3.soldQTY, 0) - ISNULL(dbo.Temp4.PurchaseQTY, 0), ISNULL(dbo.Temp4.PurchaseQTY, 0), 
                      dbo.Temp4.ControlledSubstance, dbo.Temp3.Seller_Name, dbo.Temp4.BuyerName, dbo.Temp3.URN1, dbo.Temp3.URN2, dbo.Temp4.URN1, dbo.Temp4.URN2, 
                      dbo.Temp3.Qtr_Name, dbo.Temp4.Qtr_Name, dbo.Temp3.SellerFB_ID, dbo.Temp4.BuyerFB_ID, dbo.Temp3.Buyer_Name, dbo.Temp4.Seller_Name, 
                      dbo.Temp3.SellerZone1, dbo.Temp3.SellerZone2, dbo.Temp4.BuyerZone1, dbo.Temp4.BuyerZone2, dbo.Temp4.BuyerFB_ID2, dbo.Temp3.SellerFB_ID2, 
                      dbo.Temp3.Qtr_ID, dbo.Temp4.Qtr_ID

GO
/****** Object:  Table [dbo].[tn_FormI_SubstanceCotrolled]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormI_SubstanceCotrolled](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[FI_Id] [int] NULL,
	[CS_Id] [int] NULL,
	[destroyedQty] [decimal](18, 6) NULL,
	[typeOfPackage] [varchar](250) NULL,
	[storagePlace] [varchar](1000) NULL,
	[reasons] [varchar](1000) NULL,
	[manner] [varchar](1000) NULL,
	[appearQty] [varchar](50) NULL,
	[returnFiledQty] [varchar](50) NULL,
	[addBy] [int] NULL,
	[deleted] [int] NULL,
	[destroyedQty1] [decimal](18, 3) NULL,
	[ApprovedQty] [decimal](18, 2) NULL,
	[approvedBy] [int] NULL,
	[approvedDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormI]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormI](
	[FI_Id] [int] IDENTITY(1,1) NOT NULL,
	[applicantName] [varchar](250) NULL,
	[address] [varchar](250) NULL,
	[city] [varchar](250) NULL,
	[stateId] [int] NULL,
	[pincode] [varchar](10) NULL,
	[date] [datetime] NULL,
	[place] [varchar](250) NULL,
	[signature] [varchar](250) NULL,
	[name] [varchar](250) NULL,
	[designation] [varchar](250) NULL,
	[addBy] [int] NULL,
	[deleted] [int] NULL,
	[addDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fe_ManufactureDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fe_ManufactureDetails](
	[MD_ID] [int] IDENTITY(1,1) NOT NULL,
	[FED_ID] [int] NULL,
	[mfdDate] [datetime] NULL,
	[mfdQauntity] [decimal](18, 2) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fe_ManufactureDetails] PRIMARY KEY CLUSTERED 
(
	[MD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[VW_TransactionLoginWise]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_TransactionLoginWise]
AS
SELECT     CONVERT(varchar(20), mfd.mfdDate, 107) AS date, sub.CS_ID, 'Manufacture' AS type, '' AS urn2, mfd.mfdQauntity AS qty, fe.returnQuarter AS quarter, 
                      fe.addBy AS login, fe.urnNo AS URN, fb.ZO_ID AS ZO_ID
FROM         fe_ManufactureDetails mfd INNER JOIN
                      fe_SubStanceDetails sub ON mfd.FED_ID = sub.FED_ID INNER JOIN
                      tn_FormE fe ON sub.FE_ID = fe.FE_ID INNER JOIN
                      tn_FormB fb ON fe.addBy = fb.addBy
WHERE     fe.deleted = 0 AND sub.deleted = 0 AND mfd.deleted = 0
UNION ALL
SELECT     CONVERT(varchar(20), sale.saleDate, 107) AS date, sub.CS_ID, 'Sale' AS type, sale.urnNo AS urn2, sale.consignQTY AS qty, 
                      fe.returnQuarter AS quarter, fe.addBy AS login, fe.urnNo AS URN, fb.ZO_ID AS ZO_ID
FROM         fe_SaleDetails sale INNER JOIN
                      fe_SubStanceDetails sub ON sale.FED_ID = sub.FED_ID INNER JOIN
                      tn_FormE fe ON sub.FE_ID = fe.FE_ID INNER JOIN
                      tn_FormB fb ON fe.addBy = fb.addBy
WHERE     fe.deleted = 0 AND sub.deleted = 0 AND sale.deleted = 0
UNION ALL
SELECT     CONVERT(varchar(20), frec.Add_Date, 107) AS date, frec.CS_ID, 
                      (CASE WHEN frec.Category = 1 THEN 'Import' WHEN frec.Category = 2 THEN 'Export' WHEN frec.Category = 3 THEN 'Consumption' END) AS type, 
                      frec.URN AS urn2, frec.Quantity_Received AS qty, ff.Quater AS quarter, ff.addBy AS login, ff.URN AS URN, fb.ZO_ID AS ZO_ID
FROM         ff_Receipt_Import frec INNER JOIN
                      tn_FormF ff ON frec.FF_ID = ff.FF_ID INNER JOIN
                      tn_FormB fb ON ff.addBy = fb.addBy
WHERE     frec.Deleted = 0 AND ff.deleted = 0
UNION ALL
SELECT     CONVERT(varchar(20), fi.date, 107) AS date, sub.CS_Id, 'Destroyed' AS type, '' AS urn2, sub.destroyedQty AS qty, '' AS quarter, fI.addBy AS login, 
                      fb.userRegNo AS URN, fb.ZO_ID AS ZO_ID
FROM         tn_FormI_SubstanceCotrolled sub INNER JOIN
                      tn_FormI fi ON sub.FI_Id = fi.FI_Id INNER JOIN
                      tn_FormB fb ON fi.addBy = fb.addBy
WHERE     fi.deleted = 0 AND sub.deleted = 0
GO
/****** Object:  Table [dbo].[fl_BuyerSeller]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_BuyerSeller](
	[L_ID] [int] IDENTITY(1,1) NOT NULL,
	[FL_ID] [int] NOT NULL,
	[loginId] [int] NOT NULL,
	[recordType] [int] NULL,
	[enqDate] [datetime] NULL,
	[CS_ID] [int] NULL,
	[qty] [decimal](18, 6) NULL,
	[rate] [decimal](18, 6) NULL,
	[name] [nvarchar](128) NULL,
	[address] [nvarchar](256) NULL,
	[telephoneNo] [nvarchar](16) NULL,
	[emailId] [nvarchar](64) NULL,
	[URN] [nvarchar](16) NULL,
	[ipAddress] [nvarchar](32) NULL,
	[paymentDetails] [nvarchar](128) NULL,
	[drugLicense] [nvarchar](32) NULL,
	[regObtained] [nvarchar](128) NULL,
	[status] [bit] NULL,
	[deleted] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormL]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormL](
	[FL_ID] [int] IDENTITY(1,1) NOT NULL,
	[returnQuarter] [int] NOT NULL,
	[urn] [nvarchar](16) NOT NULL,
	[brokerName] [nvarchar](128) NULL,
	[brokerAddress] [nvarchar](128) NULL,
	[portalDetails] [nvarchar](256) NULL,
	[nofEnquiries] [int] NULL,
	[returnFilledPerson] [nvarchar](128) NULL,
	[designation] [nvarchar](32) NULL,
	[returnSubmitDate] [datetime] NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [bit] NULL,
	[deleted] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ZonalOffice_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ZonalOffice_Master](
	[ZO_ID] [int] IDENTITY(1,1) NOT NULL,
	[ZonalOffice] [nvarchar](100) NULL,
	[ZonalAddress] [nvarchar](max) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_JDZO] PRIMARY KEY CLUSTERED 
(
	[ZO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[UV_FormL]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UV_FormL]
AS
SELECT        L.urn, L.brokerName, L.returnQuarter, Q.Qtr_Name, S.recordType, S.qty, S.URN AS EnqURN, S.name, C.ControlledSubstance, dbo.tn_FormB.ZO_ID, Z.ZonalOffice, 
                         CASE WHEN recordType = 1 THEN 'Seller' WHEN recordType = 2 THEN 'Buyer' END AS Activity, S.CS_ID
FROM            dbo.tn_FormB INNER JOIN
                         dbo.ZonalOffice_Master AS Z ON dbo.tn_FormB.ZO_ID = Z.ZO_ID INNER JOIN
                         dbo.tn_FormL AS L INNER JOIN
                         dbo.Quater_Master AS Q ON L.returnQuarter = Q.Qtr_ID INNER JOIN
                         dbo.fl_BuyerSeller AS S ON L.FL_ID = S.FL_ID INNER JOIN
                         dbo.ControlledSubstance_Master AS C ON S.CS_ID = C.CS_ID ON dbo.tn_FormB.addBy = L.addBy
WHERE        (L.deleted = 0) AND (S.deleted = 0)
GO
/****** Object:  Table [dbo].[fb_FurnishDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_FurnishDetails](
	[FD_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[signPersonName] [varchar](128) NULL,
	[Desig_ID] [int] NULL,
	[signPersonAddress] [varchar](256) NULL,
	[signCity] [varchar](64) NULL,
	[signPincode] [varchar](8) NULL,
	[S_ID] [int] NULL,
	[signMobileNo] [varchar](16) NULL,
	[signTelNo] [varchar](16) NULL,
	[signFaxNo] [varchar](16) NULL,
	[signEmailId] [varchar](64) NULL,
	[signPanNo] [varchar](16) NULL,
	[signPendingCases] [varchar](4) NULL,
	[signPendingCasesDetails] [varchar](512) NULL,
	[signPhotoID] [varchar](256) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fb_FurnishDetails] PRIMARY KEY CLUSTERED 
(
	[FD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[State_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[State_Master](
	[S_ID] [int] IDENTITY(1,1) NOT NULL,
	[StateName] [nvarchar](100) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_S] PRIMARY KEY CLUSTERED 
(
	[S_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NCB_AdminLoginMaster]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NCB_AdminLoginMaster](
	[loginID] [int] IDENTITY(1,1) NOT NULL,
	[userID] [varchar](64) NULL,
	[userPass] [varchar](32) NULL,
	[userPass1] [nvarchar](128) NULL,
	[UserName] [varchar](128) NULL,
	[emailID] [varchar](64) NULL,
	[mobileNo] [varchar](16) NULL,
	[altContanct] [varchar](16) NULL,
	[ZO_ID] [int] NULL,
	[accType] [int] NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[SessionId] [nvarchar](128) NULL,
	[SessionDate] [datetime] NULL,
 CONSTRAINT [PK_AdminNCB_LoginMaster] PRIMARY KEY CLUSTERED 
(
	[loginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NCB_LoginMaster]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NCB_LoginMaster](
	[loginID] [int] IDENTITY(1,1) NOT NULL,
	[userID] [varchar](64) NULL,
	[userPass] [varchar](32) NULL,
	[userPass1] [nvarchar](128) NULL,
	[applicantName] [varchar](128) NULL,
	[applyingName] [varchar](128) NULL,
	[emailID] [varchar](64) NULL,
	[mobileNo] [varchar](16) NULL,
	[altContanct] [varchar](16) NULL,
	[accType] [varchar](8) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[verficationID] [nvarchar](128) NULL,
	[IsBlacklisted] [bit] NULL,
	[SessionId] [nvarchar](128) NULL,
	[SessionDate] [datetime] NULL,
 CONSTRAINT [PK_NCB_LoginMaster] PRIMARY KEY CLUSTERED 
(
	[loginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_SigningPersonDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_SigningPersonDetails](
	[SP_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[signPersonName] [varchar](128) NULL,
	[Desig_ID] [int] NULL,
	[signPersonAddress] [varchar](256) NULL,
	[signCity] [varchar](64) NULL,
	[signPincode] [varchar](8) NULL,
	[S_ID] [int] NULL,
	[signMobileNo] [varchar](16) NULL,
	[signTelNo] [varchar](16) NULL,
	[signFaxNo] [varchar](16) NULL,
	[signEmailId] [varchar](64) NULL,
	[signPanNo] [varchar](16) NULL,
	[signPendingCases] [varchar](4) NULL,
	[signPendingCasesDetails] [varchar](512) NULL,
	[signPhotoID] [varchar](256) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fb_SigningPersonDetails] PRIMARY KEY CLUSTERED 
(
	[SP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UV_ApplicantList]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_ApplicantList]
AS
SELECT        ZM.ZonalOffice, SM.StateName, BM.FB_ID, BM.addBy, BM.tempRegNo, LM.applicantName, LM.applyingName, LM.emailID, LM.mobileNo, BM.fb_HardCopy_Rcv, 
                         BM.fb_Approval_Status, BM.fa_Generate_Status, AM1.UserName AS fb_Approval_By, AM2.UserName AS fa_Generate_By, AM3.UserName AS hcRecieved_By, 
                         CASE WHEN BM.fb_Approval_Status = 'Yes' THEN '~/admin/images/yes-icon.gif' ELSE '~/admin/images/no-icon.gif' END AS IUrl, CONVERT(varchar(12), 
                         BM.tempRegNo_Date, 103) AS tempRegNo_Date, CONVERT(varchar(12), BM.fb_HardCopy_Rcv_Date, 103) AS fb_HardCopy_Rcv_Date, CONVERT(varchar(12), 
                         BM.fa_Generate_Date, 103) AS fa_Generate_Date, CONVERT(varchar(12), BM.fb_Approval_Date, 103) AS fb_Approval_Date, 
                         CASE WHEN authorizationLetterDoc <> '' THEN 'true' WHEN signingPersonPanDoc <> '' THEN 'true' WHEN applicantPanDoc <> '' THEN 'true' WHEN importExportCodeDoc
                          <> '' THEN 'true' WHEN drugLicenceDoc <> '' THEN 'true' WHEN certificateIncorporationDoc <> '' THEN 'true' WHEN ownershipProofDoc <> '' THEN 'true' WHEN panApplyProof
                          <> '' THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_FurnishDetails
                               WHERE        signPhotoID <> '' AND FB_ID = BM.FB_ID) > 0 THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_SigningPersonDetails
                               WHERE        signPhotoID <> '' AND deleted = 0 AND FB_ID = BM.FB_ID) > 0 THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_SigningPersonDetails
                               WHERE        deleted = 0 AND FB_ID = BM.FB_ID AND signPhotoID <> '') > 0 THEN 'true' ELSE 'false' END AS dwnload, BM.deleted, BM.ZO_ID, LM.userID, 
                         BM.S_ID, BM.status, BM.userRegNo, ISNULL(BM.IsBlocked, 0) AS IsBlocked
FROM            dbo.tn_FormB AS BM INNER JOIN
                         dbo.NCB_LoginMaster AS LM ON BM.addBy = LM.loginID LEFT OUTER JOIN
                         dbo.NCB_AdminLoginMaster AS AM1 ON BM.fb_Approval_By = AM1.loginID LEFT OUTER JOIN
                         dbo.NCB_AdminLoginMaster AS AM2 ON BM.fa_Generate_By = AM2.loginID LEFT OUTER JOIN
                         dbo.NCB_AdminLoginMaster AS AM3 ON BM.hcRecieved_By = AM3.loginID LEFT OUTER JOIN
                         dbo.State_Master AS SM ON BM.S_ID = SM.S_ID LEFT OUTER JOIN
                         dbo.ZonalOffice_Master AS ZM ON BM.ZO_ID = ZM.ZO_ID

GO
/****** Object:  View [dbo].[UV_RegistrantList]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[UV_RegistrantList]
AS
SELECT        ZM.ZonalOffice, SM.StateName, BM.FB_ID, BM.userRegNo, BM.addBy, BM.tempRegNo, LM.applyingName, LM.emailID, LM.mobileNo, BM.fb_HardCopy_Rcv, 
                         BM.fb_Approval_Status, BM.fa_Generate_Status, AM1.UserName AS fb_Approval_By, AM2.UserName AS fa_Generate_By, CONVERT(varchar(12), 
                         BM.fb_HardCopy_Rcv_Date, 103) AS fb_HardCopy_Rcv_Date, CONVERT(varchar(12), BM.fa_Generate_Date, 103) AS fa_Generate_Date, CONVERT(varchar(12), 
                         BM.fb_Approval_Date, 103) AS fb_Approval_Date, 
                         CASE WHEN authorizationLetterDoc <> '' THEN 'true' WHEN signingPersonPanDoc <> '' THEN 'true' WHEN applicantPanDoc <> '' THEN 'true' WHEN importExportCodeDoc
                          <> '' THEN 'true' WHEN drugLicenceDoc <> '' THEN 'true' WHEN certificateIncorporationDoc <> '' THEN 'true' WHEN ownershipProofDoc <> '' THEN 'true' WHEN panApplyProof
                          <> '' THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_FurnishDetails
                               WHERE        signPhotoID <> '' AND FB_ID = BM.FB_ID) > 0 THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_SigningPersonDetails
                               WHERE        signPhotoID <> '' AND deleted = 0 AND FB_ID = BM.FB_ID) > 0 THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_SigningPersonDetails
                               WHERE        deleted = 0 AND FB_ID = BM.FB_ID AND signPhotoID <> '') > 0 THEN 'true' ELSE 'false' END AS dwnload, BM.ZO_ID, BM.deleted, LM.userID, 
                         ISNULL(BM.IsBlocked, 0) AS IsBlocked, BM.earlierSurrendered, BM.applicantAddress, BM.regAnotherZone1, BM.regAnotherZone2, BM.applicantName
FROM            dbo.tn_FormB AS BM LEFT OUTER JOIN
                         dbo.NCB_LoginMaster AS LM ON BM.addBy = LM.loginID LEFT OUTER JOIN
                         dbo.NCB_AdminLoginMaster AS AM1 ON BM.fb_Approval_By = AM1.loginID LEFT OUTER JOIN
                         dbo.NCB_AdminLoginMaster AS AM2 ON BM.fa_Generate_By = AM2.loginID LEFT OUTER JOIN
                         dbo.State_Master AS SM ON BM.S_ID = SM.S_ID LEFT OUTER JOIN
                         dbo.ZonalOffice_Master AS ZM ON BM.ZO_ID = ZM.ZO_ID

GO
/****** Object:  View [dbo].[UV_UserList]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_UserList]
AS
SELECT DISTINCT 
                         loginID, userID, UPPER(applicantName) AS applicantName, applyingName, emailID, mobileNo, altContanct, accType, 
                         CASE WHEN LM.Status = 0 THEN '~/admin/images/no-icon.gif' WHEN LM.Status = 1 THEN '~/admin/images/yes-icon.gif' END AS IUrl, CONVERT(varchar(15), 
                         addDate + '12:29:05', 103) AS RegDate, status, verficationID, RIGHT(CONVERT(varchar, addDate + '12:29:05', 100), 7) AS RegTime, deleted, userPass1
FROM            dbo.NCB_LoginMaster AS LM

GO
/****** Object:  View [dbo].[UV_SaleQTY]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_SaleQTY]
AS
SELECT     SUM(dbo.fe_SaleDetails.consignQTY) AS consignQTY, dbo.tn_FormE.FB_ID
FROM         dbo.fe_SaleDetails RIGHT OUTER JOIN
                      dbo.fe_SubStanceDetails ON dbo.fe_SaleDetails.FED_ID = dbo.fe_SubStanceDetails.FED_ID RIGHT OUTER JOIN
                      dbo.tn_FormE ON dbo.fe_SubStanceDetails.FE_ID = dbo.tn_FormE.FE_ID
WHERE     (dbo.fe_SaleDetails.status = 1) AND (dbo.fe_SaleDetails.deleted = 0) AND (dbo.tn_FormE.status = 1) AND (dbo.tn_FormE.deleted = 0)
GROUP BY dbo.tn_FormE.FB_ID, dbo.fe_SaleDetails.status, dbo.fe_SaleDetails.deleted, dbo.tn_FormE.status, dbo.tn_FormE.deleted


GO
/****** Object:  View [dbo].[UV_RegistrantRecord]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_RegistrantRecord]
AS
SELECT        BM.FB_ID, ZM.ZonalOffice, SM.StateName, BM.userRegNo, BM.addBy, BM.tempRegNo, LM.applyingName, LM.emailID, LM.mobileNo, BM.fb_HardCopy_Rcv, 
                         BM.fb_Approval_Status, BM.fa_Generate_Status, AM1.UserName AS fb_Approval_By, AM2.UserName AS fa_Generate_By, CONVERT(varchar(12), 
                         BM.tempRegNo_Date, 103) AS tempRegNo_Date, CONVERT(varchar(12), BM.fb_HardCopy_Rcv_Date, 103) AS fb_HardCopy_Rcv_Date, CONVERT(varchar(12), 
                         BM.fa_Generate_Date, 103) AS fa_Generate_Date, CONVERT(varchar(12), BM.fb_Approval_Date, 103) AS fb_Approval_Date, 
                         CASE WHEN authorizationLetterDoc <> '' THEN 'true' WHEN signingPersonPanDoc <> '' THEN 'true' WHEN applicantPanDoc <> '' THEN 'true' WHEN importExportCodeDoc
                          <> '' THEN 'true' WHEN drugLicenceDoc <> '' THEN 'true' WHEN certificateIncorporationDoc <> '' THEN 'true' WHEN ownershipProofDoc <> '' THEN 'true' WHEN panApplyProof
                          <> '' THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_FurnishDetails
                               WHERE        signPhotoID <> '' AND FB_ID = BM.FB_ID) > 0 THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_SigningPersonDetails
                               WHERE        signPhotoID <> '' AND deleted = 0 AND FB_ID = BM.FB_ID) > 0 THEN 'true' WHEN
                             (SELECT        COUNT(*)
                               FROM            fb_SigningPersonDetails
                               WHERE        deleted = 0 AND FB_ID = BM.FB_ID AND signPhotoID <> '') > 0 THEN 'true' ELSE 'false' END AS dwnload, BM.ZO_ID, BM.S_ID, LM.userID, 
                         BM.deleted, ISNULL(BM.IsBlocked, 0) AS IsBlocked, BM.earlierSurrendered, BM.applicantAddress, BM.regAnotherZone1, BM.regAnotherZone2, 
                         BM.applicantName
FROM            dbo.tn_FormB AS BM LEFT OUTER JOIN
                         dbo.NCB_LoginMaster AS LM ON BM.addBy = LM.loginID LEFT OUTER JOIN
                         dbo.NCB_AdminLoginMaster AS AM1 ON BM.fb_Approval_By = AM1.loginID LEFT OUTER JOIN
                         dbo.NCB_AdminLoginMaster AS AM2 ON BM.fa_Generate_By = AM2.loginID LEFT OUTER JOIN
                         dbo.State_Master AS SM ON BM.S_ID = SM.S_ID LEFT OUTER JOIN
                         dbo.ZonalOffice_Master AS ZM ON BM.ZO_ID = ZM.ZO_ID
WHERE        (BM.deleted = 0) AND (BM.status = 1)
GO
/****** Object:  View [dbo].[UV_MFDQTY]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_MFDQTY]
AS
SELECT     SUM(dbo.fe_ManufactureDetails.mfdQauntity) AS mfdQauntity, dbo.tn_FormE.FB_ID
FROM         dbo.fe_ManufactureDetails RIGHT OUTER JOIN
                      dbo.fe_SubStanceDetails ON dbo.fe_ManufactureDetails.FED_ID = dbo.fe_SubStanceDetails.FED_ID RIGHT OUTER JOIN
                      dbo.tn_FormE ON dbo.fe_SubStanceDetails.FE_ID = dbo.tn_FormE.FE_ID
WHERE     (dbo.tn_FormE.status = 1) AND (dbo.tn_FormE.deleted = 0) AND (dbo.fe_ManufactureDetails.status = 1) AND (dbo.fe_ManufactureDetails.deleted = 0)
GROUP BY dbo.tn_FormE.FB_ID, dbo.tn_FormE.status, dbo.tn_FormE.deleted, dbo.fe_ManufactureDetails.status, dbo.fe_ManufactureDetails.deleted

GO
/****** Object:  View [dbo].[UV_ActivityReport_FormE]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_ActivityReport_FormE]
AS
SELECT        ZM.ZonalOffice, FE.manufacturerName, FE.urnNo, CS.ControlledSubstance, SUM(MF.mfdQauntity) AS mfdQauntity, SUM(SL.consignQTY) AS consignQTY, 
                         'Manufacture' AS Nature_Activity, FE.deleted, FE.returnQuarter, ST.CS_ID, FB.ZO_ID
FROM            dbo.tn_FormE AS FE INNER JOIN
                         dbo.fe_SubStanceDetails AS ST ON FE.FE_ID = ST.FE_ID INNER JOIN
                         dbo.fe_ManufactureDetails AS MF ON ST.FED_ID = MF.FED_ID INNER JOIN
                         dbo.fe_SaleDetails AS SL ON ST.FED_ID = SL.FED_ID INNER JOIN
                         dbo.ControlledSubstance_Master AS CS ON ST.CS_ID = CS.CS_ID INNER JOIN
                         dbo.tn_FormB AS FB ON FE.FB_ID = FB.FB_ID INNER JOIN
                         dbo.ZonalOffice_Master AS ZM ON FB.ZO_ID = ZM.ZO_ID
GROUP BY ZM.ZonalOffice, FE.manufacturerName, FE.urnNo, CS.ControlledSubstance, FE.deleted, FE.returnQuarter, ST.CS_ID, FB.ZO_ID
HAVING        (FE.deleted = 0)

GO
/****** Object:  View [dbo].[UV_ActivityReport_FormF]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_ActivityReport_FormF]
AS
SELECT        ZM.ZonalOffice, FF.Seller_Name, FF.URN, CS.ControlledSubstance, SUM(RI.Quantity_Received) AS Quantity_Received, 
                         CASE WHEN Category = '1' THEN 'Purchase' WHEN Category = '2' THEN 'Sale' WHEN Category = '3' THEN 'Consumption' END AS Nature_Activity, FF.deleted, 
                         FF.Quater, ZM.ZO_ID, RI.CS_ID
FROM            dbo.ControlledSubstance_Master AS CS INNER JOIN
                         dbo.ff_Receipt_Import AS RI ON CS.CS_ID = RI.CS_ID INNER JOIN
                         dbo.tn_FormF AS FF ON RI.FF_ID = FF.FF_ID INNER JOIN
                         dbo.tn_FormB AS FB ON FF.loginID = FB.addBy INNER JOIN
                         dbo.ZonalOffice_Master AS ZM ON FB.ZO_ID = ZM.ZO_ID
GROUP BY ZM.ZonalOffice, FF.Seller_Name, FF.URN, CS.ControlledSubstance, RI.Category, FF.deleted, FF.Quater, ZM.ZO_ID, RI.CS_ID
HAVING        (FF.deleted = 0)

GO
/****** Object:  View [dbo].[VW_MfdWithUrn]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_MfdWithUrn]
AS
SELECT     TOP (100) PERCENT dbo.tn_FormE.urnNo, SUM(dbo.fe_ManufactureDetails.mfdQauntity) AS mfdQty, 
                      dbo.ControlledSubstance_Master.ControlledSubstance
FROM         dbo.tn_FormE INNER JOIN
                      dbo.fe_SubStanceDetails ON dbo.tn_FormE.FE_ID = dbo.fe_SubStanceDetails.FE_ID INNER JOIN
                      dbo.fe_ManufactureDetails ON dbo.fe_SubStanceDetails.FED_ID = dbo.fe_ManufactureDetails.FED_ID INNER JOIN
                      dbo.ControlledSubstance_Master ON dbo.fe_SubStanceDetails.CS_ID = dbo.ControlledSubstance_Master.CS_ID
WHERE     (dbo.fe_SubStanceDetails.deleted = 0) AND (dbo.fe_ManufactureDetails.deleted = 0)
GROUP BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance
ORDER BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance

GO
/****** Object:  View [dbo].[VW_DestroyedQty]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_DestroyedQty]
AS
SELECT        TOP (100) PERCENT dbo.tn_FormB.userRegNo AS urn, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormI_SubstanceCotrolled.destroyedQty, 
                         dbo.tn_FormI_SubstanceCotrolled.ApprovedQty
FROM            dbo.tn_FormI INNER JOIN
                         dbo.tn_FormB ON dbo.tn_FormI.addBy = dbo.tn_FormB.addBy INNER JOIN
                         dbo.ControlledSubstance_Master INNER JOIN
                         dbo.tn_FormI_SubstanceCotrolled ON dbo.ControlledSubstance_Master.CS_ID = dbo.tn_FormI_SubstanceCotrolled.CS_Id ON 
                         dbo.tn_FormI.FI_Id = dbo.tn_FormI_SubstanceCotrolled.FI_Id
GROUP BY dbo.tn_FormB.userRegNo, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormI_SubstanceCotrolled.destroyedQty, 
                         dbo.tn_FormI_SubstanceCotrolled.ApprovedQty
ORDER BY dbo.ControlledSubstance_Master.ControlledSubstance

GO
/****** Object:  View [dbo].[VW_DestroyedSubstanceQty]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_DestroyedSubstanceQty]
AS
SELECT        dbo.tn_FormI.FI_Id, SUM(dbo.tn_FormI_SubstanceCotrolled.destroyedQty) AS Qty, dbo.ControlledSubstance_Master.ControlledSubstance, 
                         SUM(dbo.tn_FormI_SubstanceCotrolled.ApprovedQty) AS AppQty
FROM            dbo.ControlledSubstance_Master INNER JOIN
                         dbo.tn_FormI_SubstanceCotrolled ON dbo.ControlledSubstance_Master.CS_ID = dbo.tn_FormI_SubstanceCotrolled.CS_Id INNER JOIN
                         dbo.tn_FormI ON dbo.tn_FormI_SubstanceCotrolled.FI_Id = dbo.tn_FormI.FI_Id
WHERE        (dbo.tn_FormI_SubstanceCotrolled.deleted = 0)
GROUP BY dbo.tn_FormI.FI_Id, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormI.deleted

GO
/****** Object:  View [dbo].[VW_MFDWithUrnAndQuarter]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_MFDWithUrnAndQuarter]
AS
SELECT     TOP (100) PERCENT dbo.tn_FormE.urnNo, SUM(dbo.fe_ManufactureDetails.mfdQauntity) AS mfdQty, 
                      dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormE.returnQuarter
FROM         dbo.tn_FormE INNER JOIN
                      dbo.fe_SubStanceDetails ON dbo.tn_FormE.FE_ID = dbo.fe_SubStanceDetails.FE_ID INNER JOIN
                      dbo.fe_ManufactureDetails ON dbo.fe_SubStanceDetails.FED_ID = dbo.fe_ManufactureDetails.FED_ID INNER JOIN
                      dbo.ControlledSubstance_Master ON dbo.fe_SubStanceDetails.CS_ID = dbo.ControlledSubstance_Master.CS_ID
WHERE     (dbo.fe_SubStanceDetails.deleted = 0) AND (dbo.fe_ManufactureDetails.deleted = 0)
GROUP BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormE.returnQuarter
ORDER BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance

GO
/****** Object:  View [dbo].[VW_SalesSubtanceWithUrn]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_SalesSubtanceWithUrn]
AS
SELECT     TOP (100) PERCENT dbo.tn_FormE.urnNo, SUM(dbo.fe_SaleDetails.consignQTY) AS soldQty, 
                      dbo.ControlledSubstance_Master.ControlledSubstance
FROM         dbo.tn_FormE INNER JOIN
                      dbo.fe_SubStanceDetails ON dbo.tn_FormE.FE_ID = dbo.fe_SubStanceDetails.FE_ID INNER JOIN
                      dbo.fe_SaleDetails ON dbo.fe_SubStanceDetails.FED_ID = dbo.fe_SaleDetails.FED_ID INNER JOIN
                      dbo.ControlledSubstance_Master ON dbo.fe_SubStanceDetails.CS_ID = dbo.ControlledSubstance_Master.CS_ID
WHERE     (dbo.fe_SubStanceDetails.deleted = 0) AND (dbo.fe_SaleDetails.deleted = 0)
GROUP BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance
ORDER BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance

GO
/****** Object:  View [dbo].[VW_SubstancesQtyUrnWise]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_SubstancesQtyUrnWise]
AS
SELECT        SUM(dbo.ff_Receipt_Import.Quantity_Received) AS RecQty, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormF.URN, dbo.ff_Receipt_Import.Category, dbo.tn_FormF.Quater
FROM            dbo.ff_Receipt_Import INNER JOIN
                         dbo.tn_FormF ON dbo.ff_Receipt_Import.FF_ID = dbo.tn_FormF.FF_ID INNER JOIN
                         dbo.ControlledSubstance_Master ON dbo.ff_Receipt_Import.CS_ID = dbo.ControlledSubstance_Master.CS_ID
GROUP BY dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormF.URN, dbo.ff_Receipt_Import.Category, dbo.tn_FormF.Quater
GO
/****** Object:  View [dbo].[VW_SubstanceQtyWithURNandQuarter]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_SubstanceQtyWithURNandQuarter]
AS
SELECT     ISNULL(SUM(dbo.ff_Receipt_Import.Quantity_Received), 0) AS RecQty, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormF.URN, 
                      dbo.ff_Receipt_Import.Category, dbo.tn_FormF.Quater, dbo.ff_Receipt_Import.CS_ID
FROM         dbo.ff_Receipt_Import INNER JOIN
                      dbo.tn_FormF ON dbo.ff_Receipt_Import.FF_ID = dbo.tn_FormF.FF_ID INNER JOIN
                      dbo.ControlledSubstance_Master ON dbo.ff_Receipt_Import.CS_ID = dbo.ControlledSubstance_Master.CS_ID
GROUP BY dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormF.URN, dbo.ff_Receipt_Import.Category, dbo.tn_FormF.Quater, 
                      dbo.ff_Receipt_Import.CS_ID
GO
/****** Object:  View [dbo].[VW_SubstanceFormE]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_SubstanceFormE]
AS
SELECT     TOP (100) PERCENT dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormE.returnQuarter
FROM         dbo.ControlledSubstance_Master INNER JOIN
                      dbo.fe_SubStanceDetails ON dbo.ControlledSubstance_Master.CS_ID = dbo.fe_SubStanceDetails.CS_ID LEFT OUTER JOIN
                      dbo.tn_FormE ON dbo.fe_SubStanceDetails.FE_ID = dbo.tn_FormE.FE_ID
GROUP BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormE.returnQuarter
ORDER BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance


GO
/****** Object:  View [dbo].[VW_SalesSubtanceWithUrnAndQuarter]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_SalesSubtanceWithUrnAndQuarter]
AS
SELECT     TOP (100) PERCENT dbo.tn_FormE.urnNo, SUM(dbo.fe_SaleDetails.consignQTY) AS soldQty, dbo.ControlledSubstance_Master.ControlledSubstance, 
                      dbo.tn_FormE.returnQuarter
FROM         dbo.tn_FormE INNER JOIN
                      dbo.fe_SubStanceDetails ON dbo.tn_FormE.FE_ID = dbo.fe_SubStanceDetails.FE_ID INNER JOIN
                      dbo.fe_SaleDetails ON dbo.fe_SubStanceDetails.FED_ID = dbo.fe_SaleDetails.FED_ID INNER JOIN
                      dbo.ControlledSubstance_Master ON dbo.fe_SubStanceDetails.CS_ID = dbo.ControlledSubstance_Master.CS_ID
WHERE     (dbo.fe_SubStanceDetails.deleted = 0) AND (dbo.fe_SaleDetails.deleted = 0)
GROUP BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance, dbo.tn_FormE.returnQuarter
ORDER BY dbo.tn_FormE.urnNo, dbo.ControlledSubstance_Master.ControlledSubstance


GO
/****** Object:  View [dbo].[UV_ComparativeReportF2F]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UV_ComparativeReportF2F]
AS
SELECT        dbo.Temp3.URN1 AS soldURN1, dbo.Temp3.URN2 AS soldURN2, dbo.Temp3.ControlledSubstance, SUM(DISTINCT ISNULL(dbo.Temp3.soldQTY, 0)) AS soldQTY, 
                         SUM(ISNULL(dbo.Temp3.soldQTY, 0) - ISNULL(dbo.Temp4.PurchaseQTY, 0)) AS Difference, dbo.Temp4.URN1 AS purchaseURN1, 
                         dbo.Temp4.URN2 AS purchaseURN2, SUM(DISTINCT ISNULL(dbo.Temp4.PurchaseQTY, 0)) AS PurchaseQTY, 
                         dbo.Temp4.ControlledSubstance AS ControlledSubstance2, dbo.Temp3.Seller_Name, dbo.Temp4.BuyerName AS Buyer_Name2, 
                         (CASE WHEN dbo.Temp3.URN1 <> '' THEN 'rptQuarterFormF.aspx?urn=' + dbo.Temp3.URN1 + '&&urn2=' + dbo.Temp3.URN2 + '&&cs=' + dbo.Temp3.ControlledSubstance
                          + '&&align=left' ELSE 'javascript:void(0);' END) AS URL, 
                         (CASE WHEN dbo.Temp4.URN1 <> '' THEN 'rptQuarterFormF.aspx?urn=' + dbo.Temp4.URN1 + '&&urn2=' + dbo.Temp4.URN2 + '&&cs=' + dbo.Temp4.ControlledSubstance
                          + '&&align=right' ELSE 'javascript:void(0);' END) AS URL2, dbo.Temp4.BuyerFB_ID, dbo.Temp3.SellerFB_ID, dbo.Temp3.Buyer_Name AS Buyer_Name1, 
                         dbo.Temp4.Seller_Name AS Seller_Name2, dbo.Temp3.SellerZone1, dbo.Temp3.SellerZone2, dbo.Temp4.BuyerZone1, dbo.Temp4.BuyerZone2, 
                         dbo.Temp3.SellerFB_ID2, dbo.Temp4.BuyerFB_ID2, dbo.Temp4.Qtr_ID AS BuyerQtrID, dbo.Temp3.Qtr_ID AS SellerQtrID
FROM            dbo.Temp4 FULL OUTER JOIN
                         dbo.Temp3 ON dbo.Temp4.URN1 = dbo.Temp3.URN2 AND dbo.Temp4.URN2 = dbo.Temp3.URN1 AND 
                         dbo.Temp4.ControlledSubstance = dbo.Temp3.ControlledSubstance
WHERE        (ISNULL(dbo.Temp3.soldQTY, 0) - ISNULL(dbo.Temp4.PurchaseQTY, 0) <> 0)
GROUP BY dbo.Temp3.ControlledSubstance, dbo.Temp4.ControlledSubstance, dbo.Temp3.Seller_Name, dbo.Temp4.BuyerName, dbo.Temp3.URN1, dbo.Temp3.URN2, 
                         dbo.Temp4.URN1, dbo.Temp4.URN2, dbo.Temp4.BuyerFB_ID, dbo.Temp3.SellerFB_ID, dbo.Temp3.Buyer_Name, dbo.Temp4.Seller_Name, dbo.Temp3.SellerZone1, 
                         dbo.Temp3.SellerZone2, dbo.Temp4.BuyerZone1, dbo.Temp4.BuyerZone2, dbo.Temp3.SellerFB_ID2, dbo.Temp4.BuyerFB_ID2, dbo.Temp4.Qtr_ID, dbo.Temp3.Qtr_ID

GO
/****** Object:  Table [dbo].[ApplicantType_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicantType_Master](
	[ATID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicantType] [nvarchar](100) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_AT] PRIMARY KEY CLUSTERED 
(
	[ATID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BlackList]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlackList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[URN] [nvarchar](16) NULL,
	[applicantName] [nvarchar](128) NULL,
	[companyName] [nvarchar](128) NULL,
	[companyPAN] [nvarchar](16) NULL,
	[companyAddress] [nvarchar](256) NULL,
	[stateId] [int] NULL,
	[zoneId] [int] NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [bit] NULL,
	[deleted] [bit] NULL,
	[FB_ID] [int] NULL,
 CONSTRAINT [PK_BlackList] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[City_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City_Master](
	[C_ID] [int] IDENTITY(1,1) NOT NULL,
	[D_ID] [int] NULL,
	[S_ID] [int] NULL,
	[cityName] [varchar](128) NULL,
	[description] [varchar](256) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_City_Master] PRIMARY KEY CLUSTERED 
(
	[C_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyDirector_Proprieter_Log]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyDirector_Proprieter_Log](
	[L_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NOT NULL,
	[applicantAddress] [varchar](256) NULL,
	[cityName] [varchar](64) NULL,
	[pincode] [varchar](8) NULL,
	[S_ID] [int] NULL,
	[mobileNo] [varchar](16) NULL,
	[telephoneNo] [varchar](16) NULL,
	[faxNo] [varchar](16) NULL,
	[emailId] [varchar](64) NULL,
	[panNo] [varchar](16) NULL,
	[applicantName_Pan] [varchar](128) NULL,
	[panApplied] [varchar](3) NULL,
	[panApplyProof] [varchar](128) NULL,
	[businessConstitution] [varchar](32) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[applicantName] [varchar](128) NULL,
 CONSTRAINT [PK_CompanyDirector_Proprieter_Log] PRIMARY KEY CLUSTERED 
(
	[L_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ControlledSubstanceReg_Log]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ControlledSubstanceReg_Log](
	[PD_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[L_ID] [int] NULL,
	[premisesAddress] [varchar](256) NULL,
	[PT_ID] [int] NULL,
	[otherPremises] [varchar](32) NULL,
	[ON_ID] [int] NULL,
	[otherOccupationNature] [varchar](32) NULL,
	[commissionate] [varchar](64) NULL,
	[division] [varchar](64) NULL,
	[range] [varchar](32) NULL,
	[address] [varchar](256) NULL,
	[contactDetails] [varchar](32) NULL,
	[CS_ID] [int] NULL,
	[NA_ID] [int] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[S_ID] [int] NULL,
	[D_ID] [int] NULL,
	[C_ID] [int] NULL,
	[pinCode] [varchar](8) NULL,
	[OthersNA] [nvarchar](64) NULL,
 CONSTRAINT [PK_ControlledSubstanceReg_Log] PRIMARY KEY CLUSTERED 
(
	[PD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Designation_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Designation_Master](
	[Desig_ID] [int] IDENTITY(1,1) NOT NULL,
	[desigName] [varchar](128) NULL,
	[description] [varchar](128) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_Designation_Master] PRIMARY KEY CLUSTERED 
(
	[Desig_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[District_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[District_Master](
	[D_ID] [int] IDENTITY(1,1) NOT NULL,
	[S_ID] [int] NULL,
	[districtName] [varchar](128) NULL,
	[description] [varchar](256) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_District_Master] PRIMARY KEY CLUSTERED 
(
	[D_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee_Master](
	[empID] [int] IDENTITY(1,1) NOT NULL,
	[empName] [varchar](128) NULL,
	[empDOB] [smalldatetime] NULL,
	[gender] [varchar](20) NULL,
	[desigID] [int] NULL,
	[department] [varchar](128) NULL,
	[address] [varchar](500) NULL,
	[countryID] [int] NULL,
	[stateID] [int] NULL,
	[city] [varchar](100) NULL,
	[pincode] [varchar](10) NULL,
	[mobileNo] [varchar](15) NULL,
	[telNo] [varchar](15) NULL,
	[phNo] [varchar](15) NULL,
	[emailID] [varchar](15) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_employee_Master] PRIMARY KEY CLUSTERED 
(
	[empID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ErrLog]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LogDESC] [varchar](2000) NULL,
	[EntryDate] [datetime] NULL,
	[ErrIn] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_BusinessTransactions]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_BusinessTransactions](
	[BT_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[departName] [varchar](256) NULL,
	[businessTransNo] [varchar](128) NULL,
	[validityUpto] [varchar](16) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fb_BusinessTransactions] PRIMARY KEY CLUSTERED 
(
	[BT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_BusinessTransactions_Log]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_BusinessTransactions_Log](
	[BT_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[departName] [varchar](256) NULL,
	[businessTransNo] [varchar](128) NULL,
	[validityUpto] [varchar](16) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fb_BusinessTransactions_Log] PRIMARY KEY CLUSTERED 
(
	[BT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_ConsumptionInfo]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_ConsumptionInfo](
	[CCS_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[CS_ID] [int] NULL,
	[description] [varchar](256) NULL,
	[rawMaterials1] [varchar](64) NULL,
	[rawMaterials2] [varchar](64) NULL,
	[rawMaterials3] [varchar](64) NULL,
	[consumptionCapacity1] [decimal](18, 2) NULL,
	[consumptionCapacity2] [decimal](18, 2) NULL,
	[consumptionCapacity3] [decimal](18, 2) NULL,
	[consumedYear1] [varchar](4) NULL,
	[consumedQTY1] [decimal](18, 2) NULL,
	[consumedYear2] [varchar](4) NULL,
	[consumedQTY2] [decimal](18, 2) NULL,
	[consumedYear3] [varchar](4) NULL,
	[consumedQTY3] [decimal](18, 2) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fb_ConsumptionInfo] PRIMARY KEY CLUSTERED 
(
	[CCS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_ControlledSubstance_SubNatureActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_ControlledSubstance_SubNatureActivity](
	[SID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[premisesAddress] [nvarchar](200) NULL,
	[CS_ID] [int] NULL,
	[S_NA_ID] [int] NULL,
	[Deleted] [tinyint] NULL,
	[Others] [nvarchar](32) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_ControlledSubstance_SubSubNatureActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_ControlledSubstance_SubSubNatureActivity](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[premisesAddress] [nvarchar](200) NULL,
	[CS_ID] [int] NULL,
	[SS_NA_ID] [int] NULL,
	[Deleted] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_Document_Required]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_Document_Required](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NOT NULL,
	[DocumentDesc] [nvarchar](1000) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fb_ManufactureInfo]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fb_ManufactureInfo](
	[MCS_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[CS_ID] [int] NULL,
	[prodCapacity1] [decimal](18, 2) NULL,
	[prodCapacity2] [decimal](18, 2) NULL,
	[prodCapacity3] [decimal](18, 2) NULL,
	[mfdYear1] [varchar](4) NULL,
	[mfdQTY1] [decimal](18, 2) NULL,
	[mfdYear2] [varchar](4) NULL,
	[mfdQTY2] [decimal](18, 2) NULL,
	[mfdYear3] [varchar](4) NULL,
	[mfdQTY3] [decimal](18, 2) NULL,
	[rawMaterials1] [varchar](64) NULL,
	[rawMaterials2] [varchar](64) NULL,
	[rawMaterials3] [varchar](64) NULL,
	[MFD_ID] [int] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_fb_ManufactureInfo] PRIMARY KEY CLUSTERED 
(
	[MCS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FormB_AddtionalDoc]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FormB_AddtionalDoc](
	[docId] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[description] [varchar](512) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_FormB_AddtionalDoc] PRIMARY KEY CLUSTERED 
(
	[docId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ManufacturedFor]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ManufacturedFor](
	[MFD_ID] [int] IDENTITY(1,1) NOT NULL,
	[ManufacturedFor] [varchar](64) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_ManufacturedFor] PRIMARY KEY CLUSTERED 
(
	[MFD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NatureActivity_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NatureActivity_Master](
	[NA_ID] [int] IDENTITY(1,1) NOT NULL,
	[NatureActivity] [nvarchar](100) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_NA] PRIMARY KEY CLUSTERED 
(
	[NA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NCB_AdminAccountType]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NCB_AdminAccountType](
	[Act_ID] [int] IDENTITY(1,1) NOT NULL,
	[Act_Name] [varchar](50) NULL,
	[Status] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NCB_LoginMaster_Log]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NCB_LoginMaster_Log](
	[loginID] [int] NOT NULL,
	[userID] [varchar](64) NULL,
	[userPass] [varchar](32) NULL,
	[userPass1] [nvarchar](128) NULL,
	[applicantName] [varchar](128) NULL,
	[applyingName] [varchar](128) NULL,
	[emailID] [varchar](64) NULL,
	[mobileNo] [varchar](16) NULL,
	[altContanct] [varchar](16) NULL,
	[accType] [varchar](8) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[verficationID] [nvarchar](128) NULL,
 CONSTRAINT [PK_NCB_LoginMaster_Log] PRIMARY KEY CLUSTERED 
(
	[loginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OccupationNature_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OccupationNature_Master](
	[ON_ID] [int] IDENTITY(1,1) NOT NULL,
	[PremisesOccupation] [nvarchar](100) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_PO] PRIMARY KEY CLUSTERED 
(
	[ON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OldURN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OldURN](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[oldURN] [nvarchar](50) NULL,
	[newURN] [nvarchar](50) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PremisesType_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PremisesType_Master](
	[PT_ID] [int] IDENTITY(1,1) NOT NULL,
	[PremisesType] [nvarchar](100) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL,
 CONSTRAINT [PK_PT] PRIMARY KEY CLUSTERED 
(
	[PT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Quarter_ReturnFiling]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Quarter_ReturnFiling](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[URN] [nvarchar](50) NULL,
	[quarter] [int] NULL,
	[totalSubURN] [int] NULL,
	[ReturnFiled] [int] NULL,
	[lastUpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Quarter_ReturnFiling] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SigningPerson_Log]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SigningPerson_Log](
	[SP_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NULL,
	[signPersonName] [varchar](128) NULL,
	[Desig_ID] [int] NULL,
	[signPersonAddress] [varchar](256) NULL,
	[signCity] [varchar](64) NULL,
	[signPincode] [varchar](8) NULL,
	[S_ID] [int] NULL,
	[signMobileNo] [varchar](16) NULL,
	[signTelNo] [varchar](16) NULL,
	[signFaxNo] [varchar](16) NULL,
	[signEmailId] [varchar](64) NULL,
	[signPanNo] [varchar](16) NULL,
	[signPendingCases] [varchar](4) NULL,
	[signPendingCasesDetails] [varchar](512) NULL,
	[signPhotoID] [varchar](256) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[L_ID] [int] NULL,
 CONSTRAINT [PK_SigningPerson_Log] PRIMARY KEY CLUSTERED 
(
	[SP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sub_NatureActivity_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sub_NatureActivity_Master](
	[S_NA_ID] [int] IDENTITY(1,1) NOT NULL,
	[NA_ID] [int] NOT NULL,
	[SubActivity] [nvarchar](50) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubSub_NatureActivity_Master]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubSub_NatureActivity_Master](
	[SS_NA_ID] [int] IDENTITY(1,1) NOT NULL,
	[S_NA_ID] [int] NOT NULL,
	[SubSubActivity] [nvarchar](50) NULL,
	[Add_By] [int] NULL,
	[Add_Date] [datetime] NULL,
	[Edit_By] [int] NULL,
	[Edit_Date] [datetime] NULL,
	[Delete_By] [int] NULL,
	[Delete_Date] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Deleted] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubURN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubURN](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parentURN] [nvarchar](50) NULL,
	[subURN] [nvarchar](50) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[FB_ID] [int] NULL,
	[PremiseAddress] [nvarchar](256) NULL,
 CONSTRAINT [PK_SubURN] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubURN_Identity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubURN_Identity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ZO_ID] [int] NOT NULL,
	[lastUsedNo] [int] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormBLog]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormBLog](
	[L_ID] [int] IDENTITY(1,1) NOT NULL,
	[FB_ID] [int] NOT NULL,
	[applicantName] [varchar](128) NULL,
	[ZO_ID] [int] NULL,
	[regAnotherZone1] [varchar](128) NULL,
	[regAnotherZone2] [varchar](128) NULL,
	[earlierSurrendered] [varchar](128) NULL,
	[applicantAddress] [varchar](256) NULL,
	[cityName] [varchar](64) NULL,
	[pincode] [varchar](8) NULL,
	[S_ID] [int] NULL,
	[mobileNo] [varchar](16) NULL,
	[telephoneNo] [varchar](16) NULL,
	[faxNo] [varchar](16) NULL,
	[emailId] [varchar](64) NULL,
	[panNo] [varchar](16) NULL,
	[applicantName_Pan] [varchar](128) NULL,
	[panApplied] [varchar](3) NULL,
	[panApplyProof] [varchar](128) NULL,
	[businessConstitution] [varchar](32) NULL,
	[conviction_PendingCases] [varchar](256) NULL,
	[orderDetails] [varchar](256) NULL,
	[declarationName] [varchar](128) NULL,
	[declareDate] [datetime] NULL,
	[declarePlace] [varchar](64) NULL,
	[signature] [varchar](128) NULL,
	[authorizationLetter] [varchar](3) NULL,
	[authorizationLetterDoc] [varchar](128) NULL,
	[signingPersonPan] [varchar](3) NULL,
	[signingPersonPanDoc] [varchar](128) NULL,
	[applicantPan] [varchar](3) NULL,
	[applicantPanDoc] [varchar](128) NULL,
	[certificateIncorporation] [varchar](3) NULL,
	[certificateIncorporationDoc] [varchar](128) NULL,
	[ownershipProof] [varchar](3) NULL,
	[ownershipProofDoc] [varchar](128) NULL,
	[drugLicence] [varchar](3) NULL,
	[drugLicenceDoc] [varchar](128) NULL,
	[importExportCode] [varchar](3) NULL,
	[importExportCodeDoc] [varchar](128) NULL,
	[addBy] [int] NULL,
	[addDate] [datetime] NULL,
	[editBy] [int] NULL,
	[editDate] [datetime] NULL,
	[deleteBy] [int] NULL,
	[deleteDate] [datetime] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
	[isSubmitted] [tinyint] NULL,
	[tempRegNo] [varchar](16) NULL,
	[userRegNo] [varchar](16) NULL,
	[userRegNo_IssueDT] [datetime] NULL,
	[fb_HardCopy_Rcv] [char](3) NULL,
	[fb_Approval_Status] [char](3) NULL,
	[fb_Approval_By] [int] NULL,
	[fa_Generate_Status] [char](3) NULL,
	[fa_Generate_By] [int] NULL,
	[stepComplete] [int] NULL,
	[tempRegNo_Date] [datetime] NULL,
	[fb_HardCopy_Rcv_Date] [datetime] NULL,
	[fa_Generate_Date] [datetime] NULL,
	[fb_Approval_Date] [datetime] NULL,
	[hcRecieved_By] [int] NULL,
 CONSTRAINT [PK_tn_FormBLog] PRIMARY KEY CLUSTERED 
(
	[L_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tn_FormG]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tn_FormG](
	[FG_Id] [int] IDENTITY(1,1) NOT NULL,
	[quarterId] [int] NULL,
	[createDate] [datetime] NULL,
	[regNoConsignor] [varchar](11) NULL,
	[nameConsignor] [varchar](250) NULL,
	[addressConsignor] [varchar](500) NULL,
	[cityConsignor] [varchar](500) NULL,
	[stateIdConsignor] [int] NULL,
	[pincodeConsignor] [varchar](10) NULL,
	[grossWeight] [decimal](18, 2) NULL,
	[netWeight] [decimal](18, 2) NULL,
	[transportMode] [varchar](250) NULL,
	[deleted] [int] NULL,
	[addBy] [int] NULL,
	[serialNo] [nvarchar](50) NULL,
	[nameConsignerMan] [varchar](250) NULL,
	[nameConsignee] [varchar](250) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tnFormG_ConsignmentDesc]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tnFormG_ConsignmentDesc](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[FG_Id] [int] NULL,
	[CS_Id] [int] NULL,
	[sentDate] [datetime] NULL,
	[URN] [varchar](50) NULL,
	[name] [varchar](250) NULL,
	[address] [varchar](250) NULL,
	[noOfPackage] [decimal](18, 2) NULL,
	[quantity] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TranLog]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TranLog](
	[ID] [int] NOT NULL,
	[actionDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[URN_Code]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[URN_Code](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[codeType] [varchar](10) NULL,
	[combination] [varchar](20) NULL,
	[combinationCode] [varchar](10) NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_URN_Code] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[URN_Identity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[URN_Identity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ZO_ID] [int] NOT NULL,
	[lastUsedNo] [int] NULL,
	[status] [tinyint] NULL,
	[deleted] [tinyint] NULL,
 CONSTRAINT [PK_URN_Identity] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApplicantType_Master] ADD  CONSTRAINT [ApplicantType_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[ApplicantType_Master] ADD  CONSTRAINT [ApplicantType_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[ApplicantType_Master] ADD  CONSTRAINT [ApplicantType_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[BlackList] ADD  CONSTRAINT [DF_BlackList_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[BlackList] ADD  CONSTRAINT [DF_BlackList_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[BlackList] ADD  CONSTRAINT [DF_BlackList_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[City_Master] ADD  CONSTRAINT [DF_City_Master_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[City_Master] ADD  CONSTRAINT [DF_City_Master_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[City_Master] ADD  CONSTRAINT [DF_City_Master_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[CompanyDirector_Proprieter_Log] ADD  CONSTRAINT [DF_CompanyDirector_Proprieter_Log_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[ControlledSubstance_Master] ADD  CONSTRAINT [ControlledSubstance_Master_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[ControlledSubstance_Master] ADD  CONSTRAINT [ControlledSubstance_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[ControlledSubstance_Master] ADD  CONSTRAINT [ControlledSubstance_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[ControlledSubstanceReg_Log] ADD  CONSTRAINT [DF_ControlledSubstanceReg_Log_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[ControlledSubstanceReg_Log] ADD  CONSTRAINT [DF_ControlledSubstanceReg_Log_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[Designation_Master] ADD  CONSTRAINT [DF_Designation_Master_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[Designation_Master] ADD  CONSTRAINT [DF_Designation_Master_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[Designation_Master] ADD  CONSTRAINT [DF_Designation_Master_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[District_Master] ADD  CONSTRAINT [DF_District_Master_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[District_Master] ADD  CONSTRAINT [DF_District_Master_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[District_Master] ADD  CONSTRAINT [DF_District_Master_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[Employee_Master] ADD  CONSTRAINT [employeeMaster_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[Employee_Master] ADD  CONSTRAINT [employee_Master_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[Employee_Master] ADD  CONSTRAINT [employee_Master_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fb_BusinessTransactions] ADD  CONSTRAINT [DF_fb_BusinessTransactions_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[fb_BusinessTransactions] ADD  CONSTRAINT [DF_fb_BusinessTransactions_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fb_ConsumptionInfo] ADD  CONSTRAINT [DF_fb_ConsumptionInfo_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[fb_ConsumptionInfo] ADD  CONSTRAINT [DF_fb_ConsumptionInfo_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fb_ControlledSubstanceReg] ADD  CONSTRAINT [DF_fb_ControlledSubstanceReg_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[fb_ControlledSubstanceReg] ADD  CONSTRAINT [DF_fb_ControlledSubstanceReg_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fb_Document_Required] ADD  CONSTRAINT [DF_fb_Document_Required_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[fb_Document_Required] ADD  CONSTRAINT [DF_fb_Document_Required_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[fb_Document_Required] ADD  CONSTRAINT [DF_fb_Document_Required_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fb_FurnishDetails] ADD  CONSTRAINT [DF_fb_FurnishDetails_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[fb_FurnishDetails] ADD  CONSTRAINT [DF_fb_FurnishDetails_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fb_ManufactureInfo] ADD  CONSTRAINT [DF_fb_ManufactureInfo_prodCapacity1]  DEFAULT ((0)) FOR [prodCapacity1]
GO
ALTER TABLE [dbo].[fb_ManufactureInfo] ADD  CONSTRAINT [DF_fb_ManufactureInfo_prodCapacity2]  DEFAULT ((0)) FOR [prodCapacity2]
GO
ALTER TABLE [dbo].[fb_ManufactureInfo] ADD  CONSTRAINT [DF_fb_ManufactureInfo_prodCapacity3]  DEFAULT ((0)) FOR [prodCapacity3]
GO
ALTER TABLE [dbo].[fb_ManufactureInfo] ADD  CONSTRAINT [DF_fb_ManufactureInfo_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[fb_ManufactureInfo] ADD  CONSTRAINT [DF_fb_ManufactureInfo_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fb_SigningPersonDetails] ADD  CONSTRAINT [DF_fb_SigningPersonDetails_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[fb_SigningPersonDetails] ADD  CONSTRAINT [DF_fb_SigningPersonDetails_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fe_ManufactureDetails] ADD  CONSTRAINT [DF_fe_ManufactureDetails_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[fe_ManufactureDetails] ADD  CONSTRAINT [DF_fe_ManufactureDetails_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fe_SaleDetails] ADD  CONSTRAINT [DF_fe_SaleDetails_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[fe_SaleDetails] ADD  CONSTRAINT [DF_fe_SaleDetails_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[fe_SubStanceDetails] ADD  CONSTRAINT [DF_fe_SubStanceDetails_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[fe_SubStanceDetails] ADD  CONSTRAINT [DF_fe_SubStanceDetails_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[ff_Receipt_Import] ADD  CONSTRAINT [DF_ff_Receipt_Import_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[ff_Receipt_Import] ADD  CONSTRAINT [DF_ff_Receipt_Import_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[ff_Receipt_Import] ADD  CONSTRAINT [DF_ff_Receipt_Import_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[fh_consignments_details] ADD  CONSTRAINT [DF_ff_Receipt_Import_Add_Date1]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[fh_consignments_details] ADD  CONSTRAINT [DF_ff_Receipt_Import_Status1]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[fh_consignments_details] ADD  CONSTRAINT [DF_ff_Receipt_Import_Deleted1]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[fl_BuyerSeller] ADD  CONSTRAINT [DF_fl_BuyerSeller_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[fl_BuyerSeller] ADD  CONSTRAINT [DF_fl_BuyerSeller_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[FormB_AddtionalDoc] ADD  CONSTRAINT [DF_FormB_AddtionalDoc_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[FormB_AddtionalDoc] ADD  CONSTRAINT [DF_FormB_AddtionalDoc_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[FormB_AddtionalDoc] ADD  CONSTRAINT [DF_FormB_AddtionalDoc_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[ManufacturedFor] ADD  CONSTRAINT [DF_ManufacturedFor_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[ManufacturedFor] ADD  CONSTRAINT [DF_ManufacturedFor_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[ManufacturedFor] ADD  CONSTRAINT [DF_ManufacturedFor_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[NatureActivity_Master] ADD  CONSTRAINT [NatureActivity_Master_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[NatureActivity_Master] ADD  CONSTRAINT [NatureActivity_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[NatureActivity_Master] ADD  CONSTRAINT [NatureActivity_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[NCB_AdminLoginMaster] ADD  CONSTRAINT [DF_NCB_AdminLoginMaster_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[NCB_AdminLoginMaster] ADD  CONSTRAINT [DF_NCB_AdminLoginMaster_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[NCB_AdminLoginMaster] ADD  CONSTRAINT [DF_NCB_AdminLoginMaster_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[NCB_LoginMaster] ADD  CONSTRAINT [DF_NCB_LoginMaster_accType]  DEFAULT ('user') FOR [accType]
GO
ALTER TABLE [dbo].[NCB_LoginMaster] ADD  CONSTRAINT [DF_NCB_LoginMaster_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[NCB_LoginMaster] ADD  CONSTRAINT [DF_NCB_LoginMaster_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[NCB_LoginMaster] ADD  CONSTRAINT [DF_NCB_LoginMaster_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[OccupationNature_Master] ADD  CONSTRAINT [PremisesOccupation_Master_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[OccupationNature_Master] ADD  CONSTRAINT [PremisesOccupation_Master_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[OccupationNature_Master] ADD  CONSTRAINT [PremisesOccupation_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[OldURN] ADD  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[OldURN] ADD  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[OldURN] ADD  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[PremisesType_Master] ADD  CONSTRAINT [PremisesType_Master_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[PremisesType_Master] ADD  CONSTRAINT [PremisesType_Master_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[PremisesType_Master] ADD  CONSTRAINT [PremisesType_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Quarter_ReturnFiling] ADD  CONSTRAINT [DF_Quarter_ReturnFiling_lastUpdatedDate]  DEFAULT (getdate()) FOR [lastUpdatedDate]
GO
ALTER TABLE [dbo].[Quater_Master] ADD  CONSTRAINT [DF_Quater_Master_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[Quater_Master] ADD  CONSTRAINT [DF_Quater_Master_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[Quater_Master] ADD  CONSTRAINT [DF_Quater_Master_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[SigningPerson_Log] ADD  CONSTRAINT [DF_SigningPerson_Log_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[SigningPerson_Log] ADD  CONSTRAINT [DF_SigningPerson_Log_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[State_Master] ADD  CONSTRAINT [State_Master_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[State_Master] ADD  CONSTRAINT [State_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[State_Master] ADD  CONSTRAINT [State_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Sub_NatureActivity_Master] ADD  CONSTRAINT [DF_Sub_NatureActivity_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[Sub_NatureActivity_Master] ADD  CONSTRAINT [DF_Sub_NatureActivity_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[SubSub_NatureActivity_Master] ADD  CONSTRAINT [DF_SubSub_NatureActivity_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[SubSub_NatureActivity_Master] ADD  CONSTRAINT [DF_SubSub_NatureActivity_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[SubURN] ADD  CONSTRAINT [DF_SubURN_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[SubURN] ADD  CONSTRAINT [DF_SubURN_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[SubURN_Identity] ADD  CONSTRAINT [DF_SubURN_Identity_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[SubURN_Identity] ADD  CONSTRAINT [DF_SubURN_Identity_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[tn_FormB] ADD  CONSTRAINT [DF_tn_FormB_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[tn_FormB] ADD  CONSTRAINT [DF_tn_FormB_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tn_FormB] ADD  CONSTRAINT [DF_tn_FormB_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[tn_FormB] ADD  CONSTRAINT [DF_tn_FormB_isSubmitted]  DEFAULT ((0)) FOR [isSubmitted]
GO
ALTER TABLE [dbo].[tn_FormB] ADD  CONSTRAINT [DF_tn_FormB_fb_HardCopy_Rcv]  DEFAULT ('No') FOR [fb_HardCopy_Rcv]
GO
ALTER TABLE [dbo].[tn_FormB] ADD  CONSTRAINT [DF_tn_FormB_fb_Approval_Status]  DEFAULT ('No') FOR [fb_Approval_Status]
GO
ALTER TABLE [dbo].[tn_FormB] ADD  CONSTRAINT [DF_tn_FormB_fa_Generate_Status]  DEFAULT ('No') FOR [fa_Generate_Status]
GO
ALTER TABLE [dbo].[tn_FormBLog] ADD  CONSTRAINT [DF_tn_FormBLog_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[tn_FormBLog] ADD  CONSTRAINT [DF_tn_FormBLog_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tn_FormBLog] ADD  CONSTRAINT [DF_tn_FormBLog_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[tn_FormBLog] ADD  CONSTRAINT [DF_tn_FormBLog_isSubmitted]  DEFAULT ((0)) FOR [isSubmitted]
GO
ALTER TABLE [dbo].[tn_FormBLog] ADD  CONSTRAINT [DF_tn_FormBLog_fb_HardCopy_Rcv]  DEFAULT ('No') FOR [fb_HardCopy_Rcv]
GO
ALTER TABLE [dbo].[tn_FormBLog] ADD  CONSTRAINT [DF_tn_FormBLog_fb_Approval_Status]  DEFAULT ('No') FOR [fb_Approval_Status]
GO
ALTER TABLE [dbo].[tn_FormBLog] ADD  CONSTRAINT [DF_tn_FormBLog_fa_Generate_Status]  DEFAULT ('No') FOR [fa_Generate_Status]
GO
ALTER TABLE [dbo].[tn_FormE] ADD  CONSTRAINT [DF_tn_FormE_addDate_1]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[tn_FormE] ADD  CONSTRAINT [DF_tn_FormE_status_1]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tn_FormE] ADD  CONSTRAINT [DF_tn_FormE_deleted_1]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[tn_FormF] ADD  CONSTRAINT [DF_tn_FormE_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[tn_FormF] ADD  CONSTRAINT [DF_tn_FormE_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tn_FormF] ADD  CONSTRAINT [DF_tn_FormE_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[tn_FormH] ADD  CONSTRAINT [DF_tn_FormE_addDate1]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[tn_FormH] ADD  CONSTRAINT [DF_tn_FormE_status1]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tn_FormH] ADD  CONSTRAINT [DF_tn_FormE_deleted1]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[tn_FormI_SubstanceCotrolled] ADD  CONSTRAINT [DF_tn_FormI_SubstanceCotrolled_approvedDate]  DEFAULT (getdate()) FOR [approvedDate]
GO
ALTER TABLE [dbo].[tn_FormL] ADD  CONSTRAINT [DF_tn_FormL_addDate]  DEFAULT (getdate()) FOR [addDate]
GO
ALTER TABLE [dbo].[tn_FormL] ADD  CONSTRAINT [DF_tn_FormL_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tn_FormL] ADD  CONSTRAINT [DF_tn_FormL_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[URN_Code] ADD  CONSTRAINT [DF_URN_Code_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[URN_Code] ADD  CONSTRAINT [DF_URN_Code_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[URN_Identity] ADD  CONSTRAINT [DF_URN_Identity_status]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[URN_Identity] ADD  CONSTRAINT [DF_URN_Identity_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[ZonalOffice_Master] ADD  CONSTRAINT [JDZonalOffice_Master_Add_Date]  DEFAULT (getdate()) FOR [Add_Date]
GO
ALTER TABLE [dbo].[ZonalOffice_Master] ADD  CONSTRAINT [JDZonalOffice_Master_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[ZonalOffice_Master] ADD  CONSTRAINT [JDZonalOffice_Master_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
/****** Object:  StoredProcedure [dbo].[Admin_Reset_Password]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Admin_Reset_Password]

(

	@userId nvarchar(64),

	@password nvarchar(128)

)

as

begin

declare @oldPass nvarchar(128)

	select @oldPass=userPass1 from NCB_AdminLoginMaster where userID=@userId and status=1 and deleted=0



	exec [USP_ResetAdminPassword1] @userId,@oldPass,@password



	select 1 as ReturnVal

end


GO
/****** Object:  StoredProcedure [dbo].[USP_Admin_Login]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_Admin_Login]       
(          
 @userID nvarchar(64),          
 @userPassword nvarchar(32)        
)          
as           
 begin        
 select * from  NCB_AdminLoginMaster where userID=@userID    
 and userPass=@userPassword and Status=1 and deleted=0         
 end 
GO
/****** Object:  StoredProcedure [dbo].[USP_Admin_Login1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_Admin_Login1]       
(          
 @userID nvarchar(64),          
 @userPassword nvarchar(256)        
)          
as           
 begin   
declare @pass nvarchar(128)
	select @pass=ltrim(replace(RIGHT(@userPassword,CHARINDEX(':',reverse(@userPassword),1)),':',''))
	
	--if exists(select * from  NCB_AdminLoginMaster where userID=@userID and userPass1=@pass and Status=1 and deleted=0)
	--BEGIN
		select *,CASE WHEN DATEDIFF(minute,SessionDate,GetDate())<45 THEN 'Y' else 'N' END Session_Date
		
		from  NCB_AdminLoginMaster where userID=@userID and userPass1=@pass and Status=1 and deleted=0         
	--END
 end 
GO
/****** Object:  StoredProcedure [dbo].[USP_Admin_ResetPassword]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_Admin_ResetPassword]
(
	@loginID int,
	@Password nvarchar(128),
	@editBy int
)
as
begin
	update NCB_LoginMaster set userPass1=@Password,editBy=editBy,editDate=Getdate() output inserted.loginID as Retval where loginId=@loginID 
end
GO
/****** Object:  StoredProcedure [dbo].[USP_AuthenticateUser]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[USP_AuthenticateUser]
(
	@UserId varchar(64),
	@Password varchar(64)
)
as
declare @Output varchar(5)
	if exists (select loginID from NCB_LoginMaster where userID=@UserId and userPass= @Password and status=1 and deleted=0)
	begin
		set @Output='User Exist'
	end
	
GO
/****** Object:  StoredProcedure [dbo].[USP_BlockRegistrant]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_BlockRegistrant]
(
	@FB_ID int,
	@loginId int
)
as
BEGIN 
	INSERT INTO BlackList(URN,applicantName,companyName,companyAddress,companyPAN,addBy,FB_ID,stateId,zoneId) 
	select userRegno,applicantName,applicantName,applicantAddress,applicantPan,@loginId,FB_ID,S_ID,ZO_ID from tn_FormB where FB_ID=@FB_ID and status=1 and deleted=0
	UPDATE tn_FormB SET IsBlocked=1,blockedDate=GETDATE(),blockedBy=@loginId where FB_ID=@FB_ID and status=1 and deleted=0
	UPDATE NCB_LoginMaster SET isBlackListed=1 where loginID=(select addBy from tn_FormB where FB_ID=@FB_ID and status=1 and deleted=0)
	select ISNULL(SCOPE_IDENTITY(),0) as Retval
END



GO
/****** Object:  StoredProcedure [dbo].[USP_BlockUsers]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_BlockUsers]
(
	@FB_ID int,
	@Login_Id int
)
as
begin
	declare @id int
	update t set t.Deleted=1,t.deleteBy=@Login_Id,deleteDate=GETDATE() output inserted.loginID as RetLogin
	
	from NCB_LoginMaster t Left outer join tn_FormB fb ON t.loginID=fb.addBy where fb.FB_ID=@FB_ID

	update tn_FormB set deleted=1,deleteBy=@Login_Id,deleteDate=GETDATE() output inserted.FB_ID as RetFB where FB_ID=@FB_ID
	
end
GO
/****** Object:  StoredProcedure [dbo].[USP_Checkurn]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_Checkurn]
(
	@urn varchar(11),
	@FB_ID int
)
as
declare @msg varchar(50)
declare @retvalue int

set @retvalue=0
if exists(select * from tn_FormB where userRegNo=@urn and deleted=0)
begin
	--if((select NA_ID from NatureActivity_Master where NatureActivity='Manufacture') in (select NA_ID from fb_ControlledSubstanceReg where FB_ID =(select TOP 1 FB_ID from tn_FormB where userRegNo=@urn and deleted=0 order by FB_ID DESC)))
	--begin
	--	set @retvalue=1
	--	set @msg='ANM'
		
	--	select @retvalue as val,@msg as msg
	--end
	if(@urn=(select TOP 1 userRegNo from tn_FormB where FB_ID=@FB_ID and deleted=0 order by FB_ID DESC))
	begin
		set @retvalue=1
		set @msg='URN could not be same as manufacturer.'
		select @retvalue as val,@msg as msg
	end
	else
	begin
		select @retvalue as val,@msg as msg,applicantName,applicantAddress from tn_FormB where userRegNo=@urn and deleted=0
	end
end
else
begin
	set @retvalue=1
		set @msg='You have entered invalid urn.'
		select @retvalue as val,@msg as msg
end

GO
/****** Object:  StoredProcedure [dbo].[USP_CheckUserActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_CheckUserActivity]
(    
 @FB_ID int     
)    
as    
declare @return int    
declare @row int  
declare @row2 int  
set @return=0  
--select @row=Row_Number() over(order by PD_ID) from fb_ControlledSubstanceReg where FB_ID=@FB_ID and NA_ID in (1,7) 
select @row=count(PD_ID) from fb_ControlledSubstanceReg where FB_ID=@FB_ID and NA_ID =1
select @row2=count(PD_ID) from fb_ControlledSubstanceReg where FB_ID=@FB_ID and NA_ID =7
-- if (@row=2)
if(@row > 0 and @row2 >0)     
 set @return=1    
else if exists(select * from fb_ControlledSubstanceReg where FB_ID=@FB_ID and NA_ID in (1) and NA_ID not in (7))      
 set @return=2    
else if exists(select * from fb_ControlledSubstanceReg where FB_ID=@FB_ID and NA_ID =7 and NA_ID <> 1)      
 set @return=3    
    
select @return as RetValue
GO
/****** Object:  StoredProcedure [dbo].[USP_ComparativeReport]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[USP_ComparativeReport] --'FTF','SR',20,0
(
	@action nvarchar(3),
	@type nvarchar(3)='',
	@Qtr_ID int=0,
	@Zone_ID int=0
)
AS
BEGIN
	if @action='FTF'
	BEGIN
		SELECT * FROM(
			Select soldURN1,soldURN2,ControlledSubstance,soldQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,(soldQTY - PurchaseQTY)Difference,
		
				   Seller_Name,Seller_Name2,Buyer_Name1,Buyer_Name2,SellerFB_ID,BuyerFB_ID,URL,URL2,SellerFB_ID2,BuyerFB_ID2,

				   (CASE WHEN (soldQTY - PurchaseQTY)=0 then 'MT' WHEN (soldQTY - PurchaseQTY)!=0 and soldURN1 is not null and purchaseURN1 is not null THEN 'MS' 
				   
				   WHEN soldURN1 is null or purchaseURN1 is null THEN 'SR' END)RStatus
	   
			from UV_ComparativeReportF2F 
			   
			where (BuyerQtrID=@Qtr_ID OR SellerQtrID=@Qtr_ID) and (SellerZone1=@Zone_ID or @Zone_ID=0) and 
		
				  (SellerZone2= @Zone_ID or @Zone_ID=0) and (BuyerZone1= @Zone_ID or @Zone_ID=0) and (BuyerZone2= @Zone_ID or @Zone_ID=0)

			)ab where (RStatus=@type or @type='')
	
	END

	IF(@action='ETF')
	BEGIN
		Select soldURN1,soldURN2,ControlledSubstance,saleQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,(saleQTY-PurchaseQTY)Difference,
		
				Seller_Name,manufacturerName,URL,URL2,SellerFB_ID,BuyerFB_ID,Buyer_Name1,Buyer_Name2,SellerFB_ID2,BuyerFB_ID2, 
				
				(CASE WHEN (saleQTY - PurchaseQTY)=0 then 'MT' WHEN (saleQTY - PurchaseQTY)!=0 and soldURN1 is not null and purchaseURN1 is not null THEN 'MS' 
				
				WHEN soldURN1 is null or purchaseURN1 is null THEN 'SR' END)RStatus

				from UV_FormE_F_ComparativeReport

				where (BuyerQtrID=@Qtr_ID OR SellerQtrID=@Qtr_ID) and (SellerZone1=@Zone_ID or @Zone_ID=0) and 
		
				  (SellerZone2= @Zone_ID or @Zone_ID=0) and (BuyerZone1= @Zone_ID or @Zone_ID=0) and (BuyerZone2= @Zone_ID or @Zone_ID=0)
	END	
END



						 
GO
/****** Object:  StoredProcedure [dbo].[USP_edit_delete_VIEWQUATERLIST]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_edit_delete_VIEWQUATERLIST]
@action varchar(250), 
@Qtr_ID int,
@loginId int  ,
@Qtr_Name nvarchar(50),
@Qtr_Desc nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
	if(@action = 'Delete')
	begin
	update Quater_Master set deleted = 1,
	deleteBy=@loginId,
	deleteDate = GETDATE()
	 where  Qtr_ID=@Qtr_ID 
	
	end

	else if(@action = 'Status')
	begin
	update Quater_Master set status =1,
	editBy=@loginId,
	editDate = GETDATE() 
	where Qtr_ID=@Qtr_ID
	end	

	else if(@action = 'EDIT')
	begin
	update Quater_Master set Qtr_Name = @Qtr_Name , Qtr_Desc = @Qtr_Desc,editBy = @loginId,editDate = GETDATE()
	where Qtr_ID = @Qtr_ID
	end



END

GO
/****** Object:  StoredProcedure [dbo].[USP_FormRecordsList]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PRoc [dbo].[USP_FormRecordsList]
(          
	 @Form varchar(2),          
	 @LoginId int=0,      
	 @ZO_ID int=0,
	 @Qtr_ID int=0,      
	 @FB_ID int=0,
	 @SearchCol varchar(20)='',
	 @SearchText varchar(50)='',
	 @Index int=0,
	 @Page int=0
)          
as           
if @Form='E'          
begin          
 select fe.FE_ID,fe.FB_ID,qm.Qtr_Name,fe.urnNo,fe.manufacturerName,fe.returnFilled, fe.addBy,Convert(varchar,fe.addDate,107)FiledDate,zm.ZonalOffice,sm.StateName,      
 
		dbo.ufn_GetSubstancesWithURNandQuarter(fe.urnNo, 'Lavel2FormESubstance', 0, fe.returnQuarter)as SubStanceName,      
 
		dbo.ufn_GetSubstancesWithURNandQuarter(fe.urnNo, 'Lavel2FormESoldQty', 0, fe.returnQuarter)as consignQTY,      
 
		dbo.ufn_GetSubstancesWithURNandQuarter(fe.urnNo, 'Lavel2FormEMFDQty', 0, fe.returnQuarter)as mfdQuantity      
       
 from tn_FormE fe inner join Quater_Master qm ON fe.returnQuarter=qm.Qtr_ID inner join tn_FormB fb ON fe.FB_ID=fb.FB_ID 
	  
	  inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID inner join State_Master sm ON fe.S_ID=sm.S_ID 
	  
 where fe.deleted=0 and (@LoginId=0 or fe.addBy=@LoginId) and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@FB_ID=0 or fb.FB_ID=@FB_ID) and (@Qtr_ID=0 or fe.returnQuarter=@Qtr_ID)      

 order by fe.FE_ID DESC          
end        
if @Form ='F'        
begin
if(@SearchCol='' and @SearchText='')  
begin      

SELECT FF_ID,FB_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,SUM(ImportQTY)ImportQTY,SUM(ExportQTY)ExportQTY,SUM(ConsumeQTY)ConsumeQTY,subURN FROM(

select ff.FF_ID,fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,Convert(varchar,ff.addDate,107)FiledDate,CASE WHEN ff.subURN is null OR ff.subURN='' THEN '' else '('+ff.SubURN+')' end SubURN,

	  (select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

      dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,      

	  SUM(CASE when RI.Category=1 then RI.Quantity_Received end) ImportQTY,SUM(CASE when RI.Category=2 then RI.Quantity_Received end) ExportQTY,

	  SUM(CASE when RI.Category=3 then RI.Quantity_Received end)ConsumeQTY

 from tn_FormF  ff LEFT OUTER join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
	  inner join State_Master sm ON ff.State_ID=sm.S_ID  left outer join tn_FormB fb on ff.addBy = fb.addBy       

 where ff.deleted=0 and (@FB_ID=0 or fb.FB_ID = @FB_ID)  and (@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID)

 group by ff.FF_ID,fb.FB_ID,Qtr_Name,ff.URN,Seller_Name,ISWithinDueDT, ff.addBy,ff.addDate,StateName,ff.loginID,Quater,ff.subURN
--union all

--select ff.FF_ID,fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,Convert(varchar,ff.addDate,107)FiledDate,

--	  (select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

--      dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,      

--	  SUM(CASE when RI.Category=1 then RI.Quantity_Received end) ImportQTY,SUM(CASE when RI.Category=2 then RI.Quantity_Received end) ExportQTY,

--	  SUM(CASE when RI.Category=3 then RI.Quantity_Received end)ConsumeQTY

-- from tn_FormF  ff inner join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
--	  inner join State_Master sm ON ff.State_ID=sm.S_ID  left outer join tn_FormB fb on ff.addBy = fb.addBy left outer join OldURN OL ON ff.URN=OL.OldURN 

-- where ff.deleted=0 and fb.FB_ID =(select FB_ID from tn_FormB where userRegNo=OL.oldURN) and OL.newURN=(select userRegNo FROM tn_FormB where FB_ID=@FB_ID) 
 
-- --and (@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID)

-- group by ff.FF_ID,fb.FB_ID,Qtr_Name,ff.URN,Seller_Name,ISWithinDueDT, ff.addBy,ff.addDate,StateName,ff.loginID,Quater
 )dsd
 group by FF_ID,FB_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,subURN

 order by FF_ID DESC

 end
else
begin

SELECT FF_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,SUM(ImportQTY)ImportQTY,SUM(ExportQTY)ExportQTY,SUM(ConsumeQTY)ConsumeQTY,subURN FROM(

select ff.FF_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,Convert(varchar,ff.addDate,107)FiledDate,CASE WHEN ff.subURN is null OR ff.subURN='' THEN '' else '('+ff.SubURN+')' end SubURN,

	  (select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

      dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,      

	  SUM(CASE when RI.Category=1 then RI.Quantity_Received end) ImportQTY,SUM(CASE when RI.Category=2 then RI.Quantity_Received end) ExportQTY,

	  SUM(CASE when RI.Category=3 then RI.Quantity_Received end)ConsumeQTY

 from tn_FormF  ff inner join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
	  inner join State_Master sm ON ff.State_ID=sm.S_ID  left outer join tn_FormB fb on ff.addBy = fb.addBy       

 where ff.deleted=0 and (@FB_ID=0 or fb.FB_ID = @FB_ID)  and (@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID) and

 (case when @SearchCol='URN' then ff.URN when @SearchCol='QTR' then qm.Qtr_Name when @SearchCol='SLR' then ff.Seller_Name when @SearchCol='STA' then sm.StateName end) like '%'+@SearchText+'%'

 group by ff.FF_ID,Qtr_Name,ff.URN,Seller_Name,ISWithinDueDT, ff.addBy,ff.addDate,StateName,ff.loginID,Quater,ff.subURN
--union all

--select ff.FF_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,Convert(varchar,ff.addDate,107)FiledDate,

--	  (select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

--      dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,      

--	  SUM(CASE when RI.Category=1 then RI.Quantity_Received end) ImportQTY,SUM(CASE when RI.Category=2 then RI.Quantity_Received end) ExportQTY,

--	  SUM(CASE when RI.Category=3 then RI.Quantity_Received end)ConsumeQTY

-- from tn_FormF  ff inner join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
--	  inner join State_Master sm ON ff.State_ID=sm.S_ID  left outer join tn_FormB fb on ff.addBy = fb.addBy left outer join OldURN OL ON ff.URN=OL.OldURN 

-- where ff.deleted=0 and fb.FB_ID =(select FB_ID from tn_FormB where userRegNo=OL.oldURN) and OL.newURN=(select userRegNo FROM tn_FormB where FB_ID=@FB_ID) 
 
-- and --(@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID) and

-- (case when @SearchCol='URN' then ff.URN when @SearchCol='QTR' then qm.Qtr_Name when @SearchCol='SLR' then ff.Seller_Name when @SearchCol='STA' then sm.StateName end) like '%'+@SearchText+'%'

-- group by ff.FF_ID,Qtr_Name,ff.URN,Seller_Name,ISWithinDueDT, ff.addBy,ff.addDate,StateName,ff.loginID,Quater
 )dsd
 group by FF_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,subURN

 order by FF_ID DESC

end    
   
end        

if @Form ='FN'        
begin
if(@SearchCol='' and @SearchText='')  
begin      

SELECT FB_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,SUM(ImportQTY)ImportQTY,SUM(ExportQTY)ExportQTY,SUM(ConsumeQTY)ConsumeQTY,addDate FROM(

select fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,Convert(varchar,ff.addDate,107)FiledDate,ff.addDate,

	  (select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

      dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,      

	  SUM(CASE when RI.Category=1 then RI.Quantity_Received end) ImportQTY,SUM(CASE when RI.Category=2 then RI.Quantity_Received end) ExportQTY,

	  SUM(CASE when RI.Category=3 then RI.Quantity_Received end)ConsumeQTY

 from tn_FormF  ff inner join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
	  inner join State_Master sm ON ff.State_ID=sm.S_ID  left outer join tn_FormB fb on ff.addBy = fb.addBy       

 where ff.deleted=0 and (@FB_ID=0 or fb.FB_ID = @FB_ID)  and (@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID)

 group by fb.FB_ID,Qtr_Name,ff.URN,Seller_Name,ISWithinDueDT, ff.addBy,ff.addDate,StateName,ff.loginID,Quater

 )dsd
 group by FB_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,addDate

 order by CONVERT(date,addDate,101) DESC

 end
else
begin

SELECT FB_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,SUM(ImportQTY)ImportQTY,SUM(ExportQTY)ExportQTY,SUM(ConsumeQTY)ConsumeQTY,addDate FROM(

select fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,Convert(varchar,ff.addDate,107)FiledDate,ff.addDate,

	  (select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

      dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,      

	  SUM(CASE when RI.Category=1 then RI.Quantity_Received end) ImportQTY,SUM(CASE when RI.Category=2 then RI.Quantity_Received end) ExportQTY,

	  SUM(CASE when RI.Category=3 then RI.Quantity_Received end)ConsumeQTY

 from tn_FormF  ff inner join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
	  inner join State_Master sm ON ff.State_ID=sm.S_ID  left outer join tn_FormB fb on ff.addBy = fb.addBy       

 where ff.deleted=0 and (@FB_ID=0 or fb.FB_ID = @FB_ID)  and (@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID) and

 (case when @SearchCol='URN' then ff.URN when @SearchCol='QTR' then qm.Qtr_Name when @SearchCol='SLR' then ff.Seller_Name when @SearchCol='STA' then sm.StateName end) like '%'+@SearchText+'%'

 group by fb.FB_ID,Qtr_Name,ff.URN,Seller_Name,ISWithinDueDT, ff.addBy,ff.addDate,StateName,ff.loginID,Quater

 )dsd
 group by FB_ID,Quater,Qtr_Name,URN,Seller_Name,ISWithinDueDT,addBy,StateName,FiledDate,ZonalOffice,SubStanceName,addDate

 order by CONVERT(date,addDate,101) DESC
 
end    
   
end
if @Form ='G'        
begin        
  select fg.FG_Id,fg.regNoConsignor,fg.nameConsignee,sm.StateName, zon.ZonalOffice, 
		
		 dbo.ufn_ConcatenateSubstances(fg.FG_Id, 'FormGSubstance', 0)as SubStanceName,      
		 
		 dbo.ufn_ConcatenateSubstances(fg.FG_Id, 'FormGQuantity', 0)as quantity      
  
  from tn_FormG fg inner join State_Master sm ON fg.stateIdConsignor=sm.S_ID       
  
		inner join tn_FormB fb on fb.addBy = fg.addBy inner join ZonalOffice_Master zon on zon.ZO_ID = fb.ZO_ID        
  
		left outer join tnFormG_ConsignmentDesc gc ON fg.FG_Id=gc.FG_Id         
        
  where fg.deleted=0 and (@LoginId=0 or fg.addBy=@LoginId) and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID)  and (@FB_ID=0 or fb.FB_ID=@FB_ID)      
  
  group by fg.FG_Id,fg.regNoConsignor,fg.nameConsignee,sm.StateName, zon.ZonalOffice      
  
  order by fg.FG_Id DESC      
end        
if @Form ='H'        
begin        
  select fh.FH_ID,fh.URN,fh.consignor_Name,qm.Qtr_Name,CONVERT(varchar(15),fh.addDate,107)FiledDate,sm.StateName, zon.ZonalOffice,        
  
		 dbo.ufn_ConcatenateSubstances(fh.FH_ID, 'FormHSubstance', 0)as SubStanceName,      
  
		 dbo.ufn_ConcatenateSubstances(fh.FH_ID, 'FormHQuantity', 0)as quantity        
  
  from tn_FormH fh inner join Quater_Master qm ON fh.Quater=qm.Qtr_ID  inner join tn_FormB fb on fb.addBy = fh.addBy inner join State_Master sm on fb.S_ID = sm.S_ID      
  
  inner join ZonalOffice_Master zon on zon.ZO_ID = fb.ZO_ID left outer join fh_consignments_details cd ON fh.Fh_Id=cd.Fh_Id       
  
  where fh.deleted=0 and (@LoginId=0 or fh.addBy=@LoginId) and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID)  and (@FB_ID=0 or fb.FB_ID=@FB_ID)      
  
  group by fh.FH_ID,fh.URN,fh.consignor_Name,qm.Qtr_Name,CONVERT(varchar(15),fh.addDate,107),sm.StateName, zon.ZonalOffice      
  
  order by fh.FH_ID DESC       
end      
if @Form ='I'      
begin      
  select fi.FI_Id,fi.applicantName,fb.userRegNo,sm.StateName, zon.ZonalOffice,ISNULL(SUM(sc.destroyedQty),0)Quantity,      
  dbo.ufn_ConcatenateSubstances(fi.FI_Id, 'DestroyedSubLavel2', 0)as SubStanceName,       
  dbo.ufn_ConcatenateSubstances(fi.FI_Id, 'DestroyedQtyLevel2', 0)as SubStanceQty,ISNULL(SUM(sc.approvedQty),0)approvedQty,
  dbo.ufn_ConcatenateSubstances(fi.FI_Id, 'AppDestroyed', 0)as SubStanceAppQty,Case when isnull(fi.status,0)=0 and fi.deleted=0 then '../admin/images/no-icon.gif' 
  WHEN isnull(fi.status,0)=1 and fi.deleted=0 then '../admin/images/yes-icon.gif' when fi.deleted=1 then '../admin/images/cancel.png' end RecStatus      ,
  CASE WHEN fi.deleted=1 or ISNULL(fi.status,0)=1 then 0 else 1 end IsEnabled
  from tn_FormI fi inner join State_Master sm ON fi.stateId = sm.S_ID      
  inner join   tn_FormB fb on fi.addBy= fb.addBy inner join ZonalOffice_Master zon on zon.ZO_ID = fb.ZO_ID       
  left outer join tn_FormI_SubstanceCotrolled sc ON fi.FI_Id=sc.FI_Id       
  where (@LoginId=0 or fi.addBy = @LoginId) and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and fi.deleted =0  and (@FB_ID=0 or fb.FB_ID=@FB_ID)      
  group by fi.FI_Id,fi.applicantName,fb.userRegNo,sm.StateName, zon.ZonalOffice, fi.status,fi.deleted     
  order by fi.FI_Id DESC      
 end      

 if @Form='FC'
 BEGIN
 if(@SearchCol='' and @SearchText='')  
	begin
		select ff.ff_ID,fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,--Convert(varchar,ff.addDate,107)FiledDate,

		(select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

		dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,ImportQTY,ExportQTY,ConsumeQTY

		from tn_FormF  ff inner join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
		inner join State_Master sm ON ff.State_ID=sm.S_ID  inner join tn_FormB fb on ff.addBy = fb.addBy
	  
		LEFT JOIN
		(
			SELECT FF_ID,SUM(CASE when Category=1 then Quantity_Received end) ImportQTY,SUM(CASE when Category=2 then Quantity_Received end) ExportQTY,

			SUM(CASE when Category=3 then Quantity_Received end) ConsumeQTY from ff_Receipt_Import group by FF_ID
		)CH ON ff.FF_ID=CH.FF_ID      

		where ff.deleted=0 and (@FB_ID=0 or fb.FB_ID = @FB_ID)  and (@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID)

		group by fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,ff.loginID,ImportQTY,ExportQTY,ConsumeQTY,ff.ff_ID

		order by ff.Quater DESC
	end
 ELSE
	begin
		select ff.ff_ID,fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,--Convert(varchar,ff.addDate,107)FiledDate,

		(select top 1 ZonalOffice from ZonalOffice_Master where ZO_ID = (select top 1 ZO_ID from tn_formB where addBy = ff.loginID))as ZonalOffice,

		dbo.ufn_GetSubstancesWithURNandQuarter(ff.URN, 'Lavel2Substance', 0, ff.Quater)as SubStanceName,ImportQTY,ExportQTY,ConsumeQTY

		from tn_FormF  ff inner join ff_Receipt_Import RI ON ff.FF_ID=RI.FF_ID inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID 
      
		inner join State_Master sm ON ff.State_ID=sm.S_ID  inner join tn_FormB fb on ff.addBy = fb.addBy
	  
		LEFT JOIN
		(
			SELECT FF_ID,SUM(CASE when Category=1 then Quantity_Received end) ImportQTY,SUM(CASE when Category=2 then Quantity_Received end) ExportQTY,

			SUM(CASE when Category=3 then Quantity_Received end) ConsumeQTY from ff_Receipt_Import  group by FF_ID
		)CH ON ff.FF_ID=CH.FF_ID      

		where ff.deleted=0 and (@FB_ID=0 or fb.FB_ID = @FB_ID)  and (@LoginId=0 or ff.addBy=@LoginId)  and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (@Qtr_ID=0 or ff.Quater=@Qtr_ID) and

		(case when @SearchCol='URN' then ff.URN when @SearchCol='QTR' then qm.Qtr_Name when @SearchCol='SLR' then ff.Seller_Name when @SearchCol='STA' then sm.StateName end) like '%'+@SearchText+'%'

		group by fb.FB_ID,ff.Quater,qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.ISWithinDueDT, ff.addBy,sm.StateName,ff.loginID,ImportQTY,ExportQTY,ConsumeQTY,ff.ff_ID

		order by ff.Quater DESC
	end
 END
GO
/****** Object:  StoredProcedure [dbo].[USP_GenerateFormA]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[USP_GenerateFormA]
(  
@FB_ID int  
)  
as  
BEGIN
select userRegNo,Convert(varchar,userRegNo_IssueDT,103)userRegNo_IssueDT,applicantName,applicantAddress,fa_Generate_Status,

Z.ZonalOffice, Z.ZonalAddress, fb.cityName, sm.StateName, fb.pincode, (SELECT TOP 1 Convert(varchar,addDate,103) from CompanyDirector_Proprieter_Log where FB_ID=FB.FB_ID order by L_ID DESC)RevisedDate 

from tn_FormB FB inner join ZonalOffice_Master Z on FB.ZO_ID=Z.ZO_ID inner join State_Master sm on fb.S_ID = sm.S_ID

where FB_ID=@FB_ID  

select csReg.premisesAddress, sm.StateName, dm.districtName, csReg.pinCode, cs.ControlledSubstance, 

dbo.ufn_GetActivityByName1(csReg.FB_ID,csReg.CS_ID,csReg.premisesAddress)NatureActivity,
--dbo.ufn_GetNatureActivityNew('Activity', csReg.FB_ID,csReg.premisesAddress)as NatureActivity,

dbo.ufn_GetSubActivityByName(csReg.FB_ID, csReg.CS_ID,csReg.premisesAddress)as SubActivity,

dbo.ufn_GetSubSubActivityByName(csReg.FB_ID, csReg.CS_ID,csReg.premisesAddress)as SubSubActivity,

isnull((select cityName from City_Master where C_ID = csReg.C_ID), 'N/A')as cityName,

(select TOP 1 subURN from SubURN where FB_ID=csReg.FB_ID and PremiseAddress=csReg.premisesAddress and deleted=0 order by id desc)SubURN

from fb_ControlledSubstanceReg csReg inner join ControlledSubstance_Master cs on csReg.CS_ID = cs.CS_ID

inner join State_Master sm on csReg.S_ID = sm.S_ID inner join District_Master dm on csReg.D_ID = dm.D_ID

INNER JOIN tn_FormB FB ON csReg.FB_ID=FB.FB_ID --LEFT OUTER JOIN SubURN SU ON FB.userRegNo=SU.parentURN and csReg.premisesAddress=SU.PremiseAddress

where csReg.FB_ID=@FB_ID and csReg.deleted = 0

group by csReg.premisesAddress, sm.StateName, dm.districtName, csReg.pinCode, cs.ControlledSubstance, csReg.FB_ID, csReg.CS_ID, csReg.C_ID

--ORDER BY csReg.PD_ID
  
--select cs.premisesAddress,csm.ControlledSubstance,na.NatureActivity from fb_ControlledSubstanceReg cs inner join PremisesType_Master pt ON 
--cs.PT_ID=pt.PT_ID inner join OccupationNature_Master oc ON cs.ON_ID=oc.ON_ID inner join ControlledSubstance_Master csm ON cs.CS_ID=csm.CS_ID 
--inner join  
--NatureActivity_Master na ON cs.NA_ID=na.NA_ID  
--where cs.FB_ID=@FB_ID

END
GO
/****** Object:  StoredProcedure [dbo].[USP_Get_ActivitySubCategoty]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_Get_ActivitySubCategoty]
(
	@action nvarchar(10)='SUB'
)
AS
BEGIN
	if(@action='SUB')
	BEGIN
		select S_NA_ID,SubActivity from Sub_NatureActivity_Master(Nolock) where status=1 and deleted=0 order by S_NA_ID
	END
	if(@action='SUBSUB')
	BEGIN
		select SS_NA_ID,SubSubActivity from SubSub_NatureActivity_Master(Nolock) where status=1 and deleted=0 order by SS_NA_ID
	END
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Get_AllMst]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_Get_AllMst]

(                  

@Mode varchar(20),                  

@ID int=0 ,            

@ZO_ID int=0,            

@AC_ID int=0,              

@SearchCol nvarchar(20)='',

@SearchText nvarchar(100)='',

@Act varchar(20)=''
)                  

as                  

if(@Mode='UNAPPUSER')                  

begin             
if (@SearchCol='' and @SearchText='')
begin
	SELECT  distinct  loginID,userID,userPass1,applicantName, applyingName, emailID, mobileNo, altContanct, accType, IUrl,RegDate, Status,verficationID,RegTime             

	FROM  UV_UserList where (@ID=0 or loginID=@ID) and deleted=0 and accType='user' and status=0            

	order by loginID DESC                
end
else
begin
	SELECT  distinct  loginID,userID,applicantName, applyingName, emailID, mobileNo, altContanct, accType, IUrl,RegDate, Status,verficationID,RegTime             

	FROM  UV_UserList where (@ID=0 or loginID=@ID) and deleted=0 and accType='user' and status=0 and case when @SearchCol='APC' then applicantName 
	
	when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID when @SearchCol='MBL' then mobileNo end like '%'+@SearchText+'%'           

	order by loginID DESC
end
end

if(@Mode='APPUSER')                  

begin             
if (@SearchCol='' and @SearchText='')
begin
	SELECT  distinct  loginID,userID,userPass1,applicantName, applyingName, emailID, mobileNo, altContanct, accType, IUrl,RegDate, Status,verficationID,RegTime             

	FROM  UV_UserList where (@ID=0 or loginID=@ID) and deleted=0 and accType='user' and status=1           

	order by loginID DESC                
end
else
begin
	SELECT  distinct  loginID,userID,applicantName, applyingName, emailID, mobileNo, altContanct, accType, IUrl,RegDate, Status,verficationID,RegTime             

	FROM  UV_UserList where (@ID=0 or loginID=@ID) and deleted=0 and accType='user' and status=1 and case when @SearchCol='APC' then applicantName 
	
	when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID when @SearchCol='MBL' then mobileNo end like '%'+@SearchText+'%'           

	order by loginID DESC
end
end             

else if(@Mode='Applicantlist')             
begin
if (@SearchCol='' and @SearchText='')
begin            

		select ZonalOffice,StateName,FB_ID,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,
		
		fb_Approval_By,fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload 
		
		from UV_ApplicantList WHERE (deleted = 0) AND (tempRegNo IS NOT NULL) and fb_Approval_Status='No' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and IsBlocked=0 
		
		order by FB_ID desc            

end            
	else
	begin 
	
		select ZonalOffice,StateName,FB_ID,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,
		
		fb_Approval_By,fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload 
		
		from UV_ApplicantList WHERE (deleted = 0) AND (tempRegNo IS NOT NULL) and fb_Approval_Status='No' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and 
		
		case when @SearchCol='TRN' then tempRegNo when @SearchCol='APC' then applicantName when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID 
		
		when @SearchCol='MBL' then mobileNo when @SearchCol='ST' then StateName when @SearchCol='ZN' then ZonalOffice end like '%'+@SearchText+'%' and IsBlocked=0
		
		order by FB_ID desc
	end
end
else if(@Mode='Registrantlist')             

begin            
	if (@SearchCol='' and @SearchText='')
	begin
	
		SELECT ZonalOffice,StateName,FB_ID,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,
			
		fb_Approval_Status,fa_Generate_Status,fb_Approval_By,fa_Generate_By,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,earlierSurrendered,
		
		(Select COUNT(1) FROM OldURN where OldURN=earlierSurrendered)IsMerged,applicantAddress,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone1,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ1,

		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone2,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ2,

		(select COUNT(distinct premiseAddress) FROM SubURN where FB_ID=UF.FB_ID and deleted=0)NSU

		FROM  UV_RegistrantList UF WHERE (deleted = 0) AND (tempRegNo IS NOT NULL) and fb_Approval_Status='Yes' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and IsBlocked=0

		order by FB_ID desc                   
	end
	else
	begin
	
		SELECT ZonalOffice,StateName,FB_ID,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,
		
		fb_Approval_Status,fa_Generate_Status,fb_Approval_By,fa_Generate_By,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,earlierSurrendered,
		
		(Select COUNT(1) FROM OldURN where OldURN=earlierSurrendered)IsMerged,applicantAddress,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone1,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ1,

		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone2,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ2,

		(select COUNT(distinct premiseAddress) FROM SubURN where FB_ID=UF.FB_ID and deleted=0)NSU

		FROM  UV_RegistrantList UF	WHERE (deleted = 0) AND (tempRegNo IS NOT NULL) and fb_Approval_Status='Yes' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and 
		
		case when @SearchCol='URN' then userRegNo when @SearchCol='APC' then applicantName when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID 
		
		when @SearchCol='MBL' then mobileNo when @SearchCol='ST' then StateName when @SearchCol='ZN' then ZonalOffice end like '%'+@SearchText+'%' and IsBlocked=0            

		order by FB_ID desc 
		
	end
end        

else if(@Mode='AdminUser')             

begin            

 SELECT     LM.loginID,LM.userID,LM.userPass1, LM.UserName, LM.emailID, LM.mobileNo, LM.altContanct, LM.accType, LM.ZO_ID, ISNULL(ZO.ZonalOffice, '')as ZonalOffice,         

                      AT.Act_Name,        

                      Case when LM.Status='1' then '~/admin/images/yes-icon.gif' else  '~/admin/images/no-icon.gif' end IUrl        

FROM         NCB_AdminLoginMaster AS LM left JOIN        

                      ZonalOffice_Master AS ZO ON LM.ZO_ID = ZO.ZO_ID left JOIN        

                      NCB_AdminAccountType AS AT ON LM.accType = AT.Act_ID          

where (@ID=0 or LM.loginID=@ID) and LM.deleted=0           

order by LM.loginID desc                                   

end        

else if(@Mode='designation')             

begin            

  SELECT     desigName, description, Desig_ID,        

  Case when Status='1' then '~/admin/images/yes-icon.gif' else  '~/admin/images/no-icon.gif' end IUrl        

FROM         Designation_Master         

where Deleted=0                                 

end        

else if(@Mode='Zonal')             

begin            

SELECT     ZO_ID, ZonalOffice,ZonalAddress,        

Case when Status='1' then '~/admin/images/yes-icon.gif' else  '~/admin/images/no-icon.gif' end IUrl        

FROM         ZonalOffice_Master        

where Deleted=0 and (ZO_ID=@ZO_Id or @ZO_Id=0) order by ZonalOffice                           

end 

else if(@Mode='Defaulters')
BEGIN
	declare @Quarter varchar(10)

	declare @endDate varchar(20)

	declare @qtrid int

	select @Quarter='Q'+CAST(DATEPART(quarter,GETDATE()) as varchar)+' '+CAST(DATEPART(YEAR,GETDATE()) as varchar)

	SELECT @qtrid=Qtr_ID FROm Quater_Master where LEFT(Qtr_Name,7)=@Quarter and Qtr_Name is not null

	select @endDate=CONVERT(varchar,Qtr_EndDate,101) from Quater_Master where Qtr_ID=@qtrid-3

	select FB_ID,F.applicantName,L.applyingName,F.mobileNo,F.emailID,Z.ZonalOffice,S.StateName,F.userRegNo 
	
	from tn_FormB F INNER JOIN ZonalOffice_Master Z ON F.ZO_ID=Z.ZO_ID INNER JOIN State_Master S ON F.S_ID=S.S_ID INNER JOIN NCB_LoginMaster L ON F.addBy=L.loginID
	
	where F.deleted=0 and ISNULL(F.IsBlocked,0)=0 and CONVERT(date,F.addDate,101)<=CONVERT(date,@endDate,101) and userRegNo is not null and
	
	F.userRegNo not in (select URN from tn_FormF where Quater=@qtrid-2 and URN=F.userRegNo) and (F.ZO_ID=@ZO_ID OR @ZO_ID=0)

END
GO
/****** Object:  StoredProcedure [dbo].[USP_Get_FL]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_Get_FL]
(
	@LoginID int
)
AS
BEGIN
	SELECT applicantName,userRegNo,applicantAddress  

	FROM tn_FormB WHERE addBy = @loginID AND deleted = 0


	SELECT CS.ControlledSubstance,C_CS.CS_ID

	FROM tn_FormB AS FB INNER JOIN fb_ControlledSubstanceReg AS C_CS ON FB.FB_ID = C_CS.FB_ID INNER JOIN ControlledSubstance_Master AS CS ON C_CS.CS_ID = CS.CS_ID  

	WHERE (FB.addBy = @loginID) AND (FB.deleted = 0) group by CS.ControlledSubstance,C_CS.CS_ID ORDER BY CS.ControlledSubstance  
  
	if exists(select * from tn_FormL where addBy=@LoginID and deleted=0)    
	begin
		select TOP 1 returnQuarter+1 as Qtr_ID from tn_FormL where addBy=@LoginID order by FL_ID DESC    
	end    
	else    
	begin  
		declare @Qtr_Name varchar(50)  
  
	   select @Qtr_Name='Q'+cast(qtr as varchar)+' '+ cast(returnyear as varchar)+' - '+
	   CAst(case when qtr=1 then 'Jan-March' when qtr=2 then 'April-June' when qtr=3 then 'July-Sept' when qtr=4 then 'Oct-Dec' else '' end as varchar)    
	   from  
	   (  
	   select (case when DATEPART(month,userRegNo_IssueDT) between 1 and 3 then 1   
		 when DATEPART(month,userRegNo_IssueDT)between 4 and 6 then 2  
		 when DATEPART(month,userRegNo_IssueDT)between 7 and 9 then 3  
		 when DATEPART(month,userRegNo_IssueDT)between 10 and 12 then 4 else '' end)qtr,  
		 DATEPART(YEAR,userRegNo_IssueDT)returnyear  
	   from tn_FormB where addBy=@LoginID and deleted=0  
	   )tmp;  

	select Qtr_ID from Quater_Master where Qtr_Name=@Qtr_Name  
 end
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Get_FormL]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_Get_FormL] 
(
	 @action nvarchar(10)='list',
	 @LoginId int=0,      
	 @ZO_ID int=0,
	 @Qtr_ID int=0,      
	 @FB_ID int=0,
	 @Id int=0,
	 @SearchCol varchar(20)='',
	 @SearchText varchar(50)=''
)
AS
BEGIN
	if(@action='list')
	BEGIN

	select FL.FL_ID,returnQuarter,Qtr_Name,FL.urn,brokerName,brokerAddress,portalDetails,nofEnquiries,returnFilledPerson,
	
	designation,CONVERT(varchar,returnSubmitDate,103)FiledDate,SUM(CASE WHEN BS.recordType=1 THEN qty else 0 END)Seller,
	
	SUM(CASE WHEN BS.recordType=2 THEN qty else 0 END)Buyer, ZO.ZonalOffice,SM.StateName
	
	from tn_FormL(NOLOCK) FL INNER JOIN Quater_Master(NOLOCK) QM ON FL.returnQuarter=QM.Qtr_ID INNER JOIN

	fl_BuyerSeller(NOLOCK) BS ON FL.FL_ID=BS.FL_ID INNER JOIN tn_FormB(NOLOCK) FB ON FL.addBy=FB.addBy INNER JOIN 
	
	ZonalOffice_Master(NOLOCK) ZO ON FB.ZO_ID=ZO.ZO_ID INNER JOIN State_Master(NOLOCK) SM ON FB.S_ID=SM.S_ID

	WHERE FL.deleted=0 and BS.deleted=0 and (FL.addBy=@LoginId OR @LoginId=0) and (fb.ZO_ID=@ZO_ID OR @ZO_ID=0) and

	(FL.returnQuarter=@Qtr_ID OR @Qtr_ID=0) and (FB.FB_ID=@FB_ID OR @FB_ID=0)

	GROUP BY FL.FL_ID,returnQuarter,Qtr_Name,FL.urn,brokerName,brokerAddress,portalDetails,nofEnquiries,
	
	returnFilledPerson,designation,returnSubmitDate, ZO.ZonalOffice,SM.StateName order by returnQuarter DESC

	END

	if(@action='details')
	BEGIN
		select returnQuarter,Qtr_Name,FL.urn,brokerName,brokerAddress,portalDetails,nofEnquiries,returnFilledPerson,
	
		designation,CONVERT(varchar,returnSubmitDate,103)returnSubmitDate
	
		from tn_FormL(NOLOCK) FL INNER JOIN Quater_Master(NOLOCK) QM ON FL.returnQuarter=QM.Qtr_ID 

		WHERE FL.deleted=0 and FL_ID=@Id

		select CONVERT(varchar,enqDate,103)enqDate,qty,rate,name,address,telephoneNo,emailId,URN,ipAddress,
		
		paymentDetails,drugLicense,regObtained,ControlledSubstance 
		
		from fl_BuyerSeller BS INNER JOIN ControlledSubstance_Master CS ON BS.CS_ID=CS.CS_ID WHERE FL_ID=@Id and recordType=1

		select CONVERT(varchar,enqDate,103)enqDate,qty,rate,name,address,telephoneNo,emailId,URN,ipAddress,
		
		paymentDetails,drugLicense,regObtained,ControlledSubstance 
		
		from fl_BuyerSeller BS INNER JOIN ControlledSubstance_Master CS ON BS.CS_ID=CS.CS_ID 
		
		WHERE FL_ID=@Id and recordType=2

		select CONVERT(varchar,enqDate,103)enqDate,qty,rate,name,address,telephoneNo,emailId,URN,ipAddress,
		
		paymentDetails,drugLicense,regObtained,ControlledSubstance 
		
		from fl_BuyerSeller BS INNER JOIN ControlledSubstance_Master CS ON BS.CS_ID=CS.CS_ID 
		
		WHERE FL_ID=@Id and recordType=2
	END
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Get_QuaterRecord]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_Get_QuaterRecord]
(
	@action nvarchar(16),
	@id int=0
)
AS
BEGIN
	
	if(@action='edit')
	BEGIN
		select Qtr_ID,Qtr_Name,Qtr_Desc,CONVERT(nvarchar,Qtr_EndDate,103) Qtr_EndDate from Quater_Master where Qtr_ID=@id
	END
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Get_Registrants_ActivityWise]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_Get_Registrants_ActivityWise] 
(
	@NAID int
)
AS
BEGIN
	SELECT FB_ID,ZonalOffice,userRegNo,applicantName,applicantAddress,StateName,mobileNo,NatureOfActivity,Substance FROM(
		SELECT FB.FB_ID, FB.applicantName, REPLACE(REPLACE(REPLACE(FB.applicantAddress,char(9),''),char(10),''),char(13),'')applicantAddress, 
		FB.cityName, FB.pincode, FB.mobileNo,StateName, FB.userRegNo,ZM.ZonalOffice,
		[dbo].[ufn_GetNatureActivity_New]('Activity',FB.FB_ID)NatureOfActivity,[dbo].[ufn_GetSubstance](FB.FB_ID)Substance
		FROM tn_FormB(NOLOCK) FB INNER JOIN fb_ControlledSubstanceReg(NOLOCK) CS ON FB.FB_ID = CS.FB_ID INNER JOIN 
		State_Master(NOLOCK) S ON FB.S_ID=S.S_ID INNER JOIN ZonalOffice_Master(NOLOCK) ZM ON FB.ZO_ID=ZM.ZO_ID INNER JOIN NatureActivity_Master(NOLOCK) NA ON CS.NA_ID=NA.NA_ID
		WHERE FB.status=1 and FB.deleted=0 and userRegNo is not null and CS.NA_ID=@NAID and CS.deleted=0 and ISNULL(FB.IsBlocked,0)=0
		group by ZonalOffice,FB.applicantName, FB.applicantAddress, FB.cityName, FB.pincode, FB.mobileNo,StateName, FB.userRegNo,FB.FB_ID,CS_ID
	)ds group by FB_ID,ZonalOffice,applicantName,applicantAddress,cityName,pincode,mobileNo,StateName,userRegNo,NatureOfActivity,Substance
	order by FB_ID
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GET_SubURN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_GET_SubURN]
(
	@FB_ID int,
	@PD_ID nvarchar(400),
	@returncode varchar(20) OUTPUT
)
as
	declare @zone varchar(2)
	declare @activity varchar(2)
	declare @substance varchar(2)
	declare @serialno int
	declare @urn varchar(15)
	-- Find Zone Code
	select @zone=combinationCode from URN_Code 
	where status=1 and deleted=0 and codeType='Zone' and combination=(select ZO_ID from tn_FormB where FB_ID=@FB_ID and deleted=0)
	
	-- Find Activity Code
	if (select COUNT(distinct NA_ID) from fb_ControlledSubstanceReg where PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)) and deleted=0) > 1
	begin
		if exists (select NA_ID from fb_ControlledSubstanceReg where NA_ID=1 and deleted=0 and PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)))
		begin
			set @activity='MD'
		end
		else if exists (select NA_ID from fb_ControlledSubstanceReg where NA_ID=7 and deleted=0 and PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)))
		begin
			set @activity='CD'
		end
		else if exists (select NA_ID from fb_ControlledSubstanceReg where NA_ID not in (1,7) and deleted=0 and PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)))
		begin
			set @activity='DL'
		end
	end
	else
	begin
		select @activity=combinationCode from URN_Code 
		where status=1 and deleted=0 and codeType='Activity' and combination=(select distinct NA_ID from fb_ControlledSubstanceReg where PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)) and deleted=0)
	end
	
	-- Find Controlled Substance Code
	
	if (select COUNT(distinct CS_ID) from fb_ControlledSubstanceReg where PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)) and deleted=0) = 1
	begin
		select @substance=combinationCode from URN_Code 
		where status=1 and deleted=0 and codeType='Substance' and 
		combination=Convert(varchar,(select distinct CS_ID from fb_ControlledSubstanceReg where PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)) and deleted=0))
	end
	else
	begin
		declare @result varchar(20)
		select @result=COALESCE(@result+',','')+convert(varchar,CS_ID) from fb_ControlledSubstanceReg where PD_ID in (select value from dbo.fnNTextToIntTable(@PD_ID)) and deleted=0 group by CS_ID order by CS_ID 
		
		select @substance=combinationCode from URN_Code 
		where status=1 and deleted=0 and codeType='Substance' and combination=@result
	end
	
	select @serialno=isnull(lastUsedNo,0)+1 from SubURN_Identity where deleted=0 and 
	ZO_ID=(select ZO_ID from tn_FormB where FB_ID=@FB_ID and deleted=0)
	declare @serial varchar(10)
	set @serial='000000'+convert(varchar,@serialno)
	select @serial=RIGHT(@serial,5)
	
	set @urn=@zone+@activity+@substance+@serial
	IF EXISTS(SELECT COUNT(*) FROM SubURN_Identity where deleted=0 and ZO_ID=(select ZO_ID from tn_FormB where FB_ID=@FB_ID and deleted=0))
	BEGIN
	update SubURN_Identity set lastUsedNo=@serialno where deleted=0 and ZO_ID=(select ZO_ID from tn_FormB where FB_ID=@FB_ID and deleted=0)
	END
	ELSE
	BEGIN
		INSERT INTO SubURN_Identity(ZO_ID,lastUsedNo,status,deleted) select ZO_ID,@serialno,1,0 from tn_FormB where FB_ID=@FB_ID and deleted=0
	END
	select @returncode=@urn
GO
/****** Object:  StoredProcedure [dbo].[USP_GET_URN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_GET_URN]
(
	@FB_ID int,
	@returncode varchar(20) OUTPUT
)
as
	
	declare @zone varchar(2)
	declare @activity varchar(2)
	declare @substance varchar(2)
	declare @serialno int
	declare @urn varchar(11)
	-- Find Zone Code
	select @zone=combinationCode from URN_Code 
	where status=1 and deleted=0 and codeType='Zone' and combination=(select ZO_ID from tn_FormB where FB_ID=@FB_ID and deleted=0)
	
	-- Find Activity Code
	if (select COUNT(distinct NA_ID) from fb_ControlledSubstanceReg where FB_ID=@FB_ID and deleted=0) > 1
	begin
		if exists (select NA_ID from fb_ControlledSubstanceReg where NA_ID=1 and deleted=0 and FB_ID=@FB_ID)
		begin
			set @activity='MD'
		end
		else if exists (select NA_ID from fb_ControlledSubstanceReg where NA_ID=7 and deleted=0 and FB_ID=@FB_ID)
		begin
			set @activity='CD'
		end
		else if exists (select NA_ID from fb_ControlledSubstanceReg where NA_ID not in (1,7) and deleted=0 and FB_ID=@FB_ID)
		begin
			set @activity='DL'
		end
	end
	else
	begin
		select @activity=combinationCode from URN_Code 
		where status=1 and deleted=0 and codeType='Activity' and combination=(select distinct NA_ID from fb_ControlledSubstanceReg where FB_ID=@FB_ID and deleted=0)
	end
	
	-- Find Controlled Substance Code
	
	if (select COUNT(distinct CS_ID) from fb_ControlledSubstanceReg where FB_ID=@FB_ID and deleted=0) = 1
	begin
		select @substance=combinationCode from URN_Code 
		where status=1 and deleted=0 and codeType='Substance' and 
		combination=Convert(varchar,(select TOP 1 CS_ID from fb_ControlledSubstanceReg where FB_ID=@FB_ID and deleted=0 group by CS_ID))
	end
	else
	begin
		declare @result varchar(20)
		select @result=COALESCE(@result+',','')+convert(varchar,CS_ID) from fb_ControlledSubstanceReg where FB_ID=@FB_ID and deleted=0 group by CS_ID order by CS_ID 
		
		select @substance=combinationCode from URN_Code 
		where status=1 and deleted=0 and codeType='Substance' and combination=@result
	end
	
	select @serialno=isnull(lastUsedNo,0)+1 from URN_Identity where deleted=0 and 
	ZO_ID=(select ZO_ID from tn_FormB where FB_ID=@FB_ID and deleted=0)
	declare @serial varchar(10)
	set @serial='000000'+convert(varchar,@serialno)
	select @serial=RIGHT(@serial,5)
	
	set @urn=@zone+@activity+@substance+@serial
	
	update URN_Identity set lastUsedNo=@serialno where deleted=0 and 
	ZO_ID=(select ZO_ID from tn_FormB where FB_ID=@FB_ID and deleted=0)
	
	select @returncode=@urn
GO
/****** Object:  StoredProcedure [dbo].[USP_Get_Value_For_DropDown]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_Get_Value_For_DropDown]        
(        
@TableName varchar(100),        
@WhereCond varchar(300)        
)        
as         
begin        
 declare @query varchar(1000)        
 set @query='select * from '+' '+@TableName+' '+@WhereCond;        
 exec(@query);        
end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetAll_FormB]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_GetAll_FormB]
(  
 @FB_ID int,
 @mode varchar(10)='current'
)  
as 
BEGIN 
if(@mode='current')
BEGIN
	select fb.applicantName,(fb.regAnotherZone1+'<br/>'+fb.regAnotherZone2)RegisterZone,fb.earlierSurrendered,fb.applicantAddress,fb.cityName,fb.pincode,fb.mobileNo,

	fb.telephoneNo,fb.faxNo,fb.emailId,fb.panNo,fb.applicantName_Pan,fb.panApplied,fb.panApplyProof,fb.businessConstitution,fb.conviction_PendingCases,fb.orderDetails,

	fb.declarationName,Convert(varchar(30),fb.declareDate,103)declareDate,fb.declarePlace,fb.signature,fb.authorizationLetter,fb.authorizationLetterDoc,fb.signingPersonPan,

	fb.signingPersonPanDoc,fb.applicantPan,fb.applicantPanDoc,fb.certificateIncorporation,fb.certificateIncorporationDoc,fb.ownershipProof,fb.ownershipProofDoc,fb.drugLicence,

	fb.drugLicenceDoc,fb.importExportCode,fb.importExportCodeDoc,zo.ZonalOffice,sm.StateName,fb.isSubmitted  

	from tn_FormB fb inner join ZonalOffice_Master zo ON fb.ZO_ID=zo.ZO_ID inner join State_Master sm ON fb.S_ID=sm.S_ID  

	where fb.FB_ID=@FB_ID and fb.deleted=0
  
	select cs.premisesAddress,(Case cs.PT_ID when 4 then cs.otherPremises else pt.PremisesType end)Premises,  

	(Case cs.ON_ID when 5 then cs.otherOccupationNature else oc.PremisesOccupation end)Occupation,  

	(cs.commissionate+'<br/>'+cs.division+'<br/>'+cs.range+'<br/>'+cs.address+'<br/>'+cs.contactDetails)Details,  

	csm.ControlledSubstance,dbo.ufn_GetActivityByName1(cs.FB_ID,cs.CS_ID,cs.premisesAddress)NatureActivity,
	
	dbo.ufn_GetSubActivityByName(cs.FB_ID,cs.CS_ID,cs.premisesAddress)SubActivity,
	
	dbo.ufn_GetSubSubActivityByName(cs.FB_ID,cs.CS_ID,cs.premisesAddress)SubSubActivity,

	sm.StateName,dm.districtName,cm.cityName,cs.pinCode  

	from fb_ControlledSubstanceReg cs inner join PremisesType_Master pt ON cs.PT_ID=pt.PT_ID inner join  

	OccupationNature_Master oc ON cs.ON_ID=oc.ON_ID inner join ControlledSubstance_Master csm ON cs.CS_ID=csm.CS_ID inner join 

	State_Master sm ON cs.S_ID=sm.S_ID  left outer join District_Master dm ON cs.D_ID=dm.D_ID left outer join City_Master cm ON cs.C_ID=cm.C_ID  

	where cs.FB_ID=@FB_ID  and cs.deleted=0

	group by cs.premisesAddress,(Case cs.PT_ID when 4 then cs.otherPremises else pt.PremisesType end),(Case cs.ON_ID when 5 then cs.otherOccupationNature else oc.PremisesOccupation end),  

	(cs.commissionate+'<br/>'+cs.division+'<br/>'+cs.range+'<br/>'+cs.address+'<br/>'+cs.contactDetails),csm.ControlledSubstance,cs.FB_ID,cs.CS_ID,sm.StateName,dm.districtName,cm.cityName,cs.pinCode  
  
	select cs.ControlledSubstance,replace(mi.prodCapacity1,'.00','')prodCapacity1,replace(mi.prodCapacity2,'.00','')prodCapacity2,replace(mi.prodCapacity3,'.00','')prodCapacity3,

	mi.mfdYear1,replace(mi.mfdQTY1,'.00','')mfdQTY1,mi.mfdYear2,replace(mi.mfdQTY2,'.00','')mfdQTY2,mi.mfdYear3,replace(mi.mfdQTY3,'.00','')mfdQTY3,mi.rawMaterials1,mi.rawMaterials2,

	mi.rawMaterials3,mf.ManufacturedFor  
  
	from fb_ManufactureInfo mi inner join ControlledSubstance_Master cs ON mi.CS_ID=cs.CS_ID inner join ManufacturedFor mf ON mi.MFD_ID=mf.MFD_ID  

	where mi.FB_ID=@FB_ID  and mi.deleted=0
  
	select cs.ControlledSubstance,ci.description,replace(ci.consumptionCapacity1,'.00','')consumptionCapacity1,  

	replace(ci.consumptionCapacity2,'.00','')consumptionCapacity2,replace(ci.consumptionCapacity3,'.00','')consumptionCapacity3,ci.consumedYear1,  

	replace(ci.consumedQTY1,'.00','')consumedQTY1,ci.consumedYear2,replace(ci.consumedQTY2,'.00','')consumedQTY2,ci.consumedYear3,  

	replace(ci.consumedQTY3,'.00','')consumedQTY3,ci.rawMaterials1,ci.rawMaterials2,ci.rawMaterials3  
  
	from fb_ConsumptionInfo ci inner join ControlledSubstance_Master cs ON ci.CS_ID=cs.CS_ID  

	where ci.FB_ID=@FB_ID  and ci.deleted=0
  
	select sd.signPersonName,dm.desigName,sd.signPersonAddress,sd.signCity,sd.signPincode,sm.StateName,sd.signMobileNo,sd.signTelNo,sd.signFaxNo,sd.signEmailId,sd.signPanNo,

	sd.signPendingCases,sd.signPendingCasesDetails,(case sd.signPhotoID when '' then 'N/A' else sd.signPhotoID end)signPhotoID  

	from fb_SigningPersonDetails sd inner join Designation_Master dm ON sd.Desig_ID=dm.Desig_ID inner join State_Master sm ON sd.S_ID=sm.S_ID  

	where sd.FB_ID=@FB_ID  and sd.deleted=0
  
	select departName,businessTransNo,validityUpto from fb_BusinessTransactions where FB_ID=@FB_ID  and deleted=0

	select L_ID,FB_ID,ROW_Number() over(order by L_ID desc)RN from CompanyDirector_Proprieter_Log where FB_ID=@FB_ID and deleted=0
END

if(@mode='history')
BEGIN
	select DP.applicantName,(fb.regAnotherZone1+'<br/>'+fb.regAnotherZone2)RegisterZone,fb.earlierSurrendered,DP.applicantAddress,DP.cityName,DP.pincode,DP.mobileNo,

	DP.telephoneNo,DP.faxNo,DP.emailId,DP.panNo,DP.applicantName_Pan,DP.panApplied,DP.panApplyProof,DP.businessConstitution,fb.conviction_PendingCases,fb.orderDetails,

	fb.declarationName,Convert(varchar(30),fb.declareDate,103)declareDate,fb.declarePlace,fb.signature,fb.authorizationLetter,fb.authorizationLetterDoc,fb.signingPersonPan,

	fb.signingPersonPanDoc,fb.applicantPan,fb.applicantPanDoc,fb.certificateIncorporation,fb.certificateIncorporationDoc,fb.ownershipProof,fb.ownershipProofDoc,fb.drugLicence,

	fb.drugLicenceDoc,fb.importExportCode,fb.importExportCodeDoc,zo.ZonalOffice,sm.StateName,fb.isSubmitted  

	from tn_FormB fb inner join ZonalOffice_Master zo ON fb.ZO_ID=zo.ZO_ID inner join State_Master sm ON fb.S_ID=sm.S_ID INNER JOIN  CompanyDirector_Proprieter_Log DP ON fb.FB_ID=DP.FB_ID

	where DP.L_ID=@FB_ID and fb.deleted=0
  
	select cs.premisesAddress,(Case cs.PT_ID when 4 then cs.otherPremises else pt.PremisesType end)Premises,  

	(Case cs.ON_ID when 5 then cs.otherOccupationNature else oc.PremisesOccupation end)Occupation,  

	(cs.commissionate+'<br/>'+cs.division+'<br/>'+cs.range+'<br/>'+cs.address+'<br/>'+cs.contactDetails)Details,  

	csm.ControlledSubstance,dbo.ufn_GetLActivityByName1(cs.FB_ID,cs.CS_ID,cs.premisesAddress)NatureActivity,  

	sm.StateName,dm.districtName,cm.cityName,cs.pinCode  

	from ControlledSubstanceReg_Log cs inner join PremisesType_Master pt ON cs.PT_ID=pt.PT_ID inner join  

	OccupationNature_Master oc ON cs.ON_ID=oc.ON_ID inner join ControlledSubstance_Master csm ON cs.CS_ID=csm.CS_ID inner join 

	State_Master sm ON cs.S_ID=sm.S_ID  left outer join District_Master dm ON cs.D_ID=dm.D_ID left outer join City_Master cm ON cs.C_ID=cm.C_ID  

	where cs.L_ID=@FB_ID  and cs.deleted=0

	group by cs.premisesAddress,(Case cs.PT_ID when 4 then cs.otherPremises else pt.PremisesType end),(Case cs.ON_ID when 5 then cs.otherOccupationNature else oc.PremisesOccupation end),  

	(cs.commissionate+'<br/>'+cs.division+'<br/>'+cs.range+'<br/>'+cs.address+'<br/>'+cs.contactDetails),csm.ControlledSubstance,cs.FB_ID,cs.CS_ID,sm.StateName,dm.districtName,cm.cityName,cs.pinCode  
  
	select cs.ControlledSubstance,replace(mi.prodCapacity1,'.00','')prodCapacity1,replace(mi.prodCapacity2,'.00','')prodCapacity2,replace(mi.prodCapacity3,'.00','')prodCapacity3,

	mi.mfdYear1,replace(mi.mfdQTY1,'.00','')mfdQTY1,mi.mfdYear2,replace(mi.mfdQTY2,'.00','')mfdQTY2,mi.mfdYear3,replace(mi.mfdQTY3,'.00','')mfdQTY3,mi.rawMaterials1,mi.rawMaterials2,

	mi.rawMaterials3,mf.ManufacturedFor  
  
	from fb_ManufactureInfo mi inner join ControlledSubstance_Master cs ON mi.CS_ID=cs.CS_ID inner join ManufacturedFor mf ON mi.MFD_ID=mf.MFD_ID  

	where mi.FB_ID=@FB_ID  and mi.deleted=0
  
	select cs.ControlledSubstance,ci.description,replace(ci.consumptionCapacity1,'.00','')consumptionCapacity1,  

	replace(ci.consumptionCapacity2,'.00','')consumptionCapacity2,replace(ci.consumptionCapacity3,'.00','')consumptionCapacity3,ci.consumedYear1,  

	replace(ci.consumedQTY1,'.00','')consumedQTY1,ci.consumedYear2,replace(ci.consumedQTY2,'.00','')consumedQTY2,ci.consumedYear3,  

	replace(ci.consumedQTY3,'.00','')consumedQTY3,ci.rawMaterials1,ci.rawMaterials2,ci.rawMaterials3  
  
	from fb_ConsumptionInfo ci inner join ControlledSubstance_Master cs ON ci.CS_ID=cs.CS_ID  

	where ci.FB_ID=@FB_ID  and ci.deleted=0
  
	select sd.signPersonName,dm.desigName,sd.signPersonAddress,sd.signCity,sd.signPincode,sm.StateName,sd.signMobileNo,sd.signTelNo,sd.signFaxNo,sd.signEmailId,sd.signPanNo,

	sd.signPendingCases,sd.signPendingCasesDetails,(case sd.signPhotoID when '' then 'N/A' else sd.signPhotoID end)signPhotoID  

	from SigningPerson_Log sd inner join Designation_Master dm ON sd.Desig_ID=dm.Desig_ID inner join State_Master sm ON sd.S_ID=sm.S_ID  

	where sd.L_ID=@FB_ID  and sd.deleted=0
	
	if exists(SELECT * from fb_BusinessTransactions_Log where FB_ID=@FB_ID and deleted=0)
	BEGIN
		select departName,businessTransNo,validityUpto from fb_BusinessTransactions_Log where FB_ID=@FB_ID  and deleted=0
	END
	ELSE
	BEGIN
		select departName,businessTransNo,validityUpto from fb_BusinessTransactions where FB_ID=@FB_ID  and deleted=0
	END
	select L_ID,FB_ID,ROW_Number() over(order by L_ID desc)RN from CompanyDirector_Proprieter_Log where FB_ID=@FB_ID and deleted=0
END
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetCompany_Director_Report]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_GetCompany_Director_Report] --'','','Surinder Kumar Garg'
(
	@URN nvarchar(16)='',
	@CompanyName nvarchar(128)='',
	@AuthorizedPerson nvarchar(128)='',
	@address nvarchar(250)=''
)
as
BEGIN
	select FB.userRegNo,FB.applicantName,SP.signPersonName,CS.address,(CASE WHEN FB.deleted=1 then 'De-Activated' WHEN FB.isBlocked=1 then 'Back Listed' ELSE 'Active' END)REGStatus 

	from tn_formB FB INNER JOIN fb_ControlledSubstanceReg CS ON FB.FB_ID=CS.FB_ID INNER JOIN fb_SigningPersonDetails SP ON FB.FB_ID=SP.FB_ID 

	where FB.isSubmitted=1 and FB.userRegNo is not null and FB.status=1 and CS.deleted=0 and SP.deleted=0 and (FB.userRegNo=@URN or @URN='') and 
	
	(FB.applicantName like '%'+@CompanyName+'%' or @CompanyName='') and (SP.signPersonName like '%'+@AuthorizedPerson+'%' or @AuthorizedPerson='') and (FB.applicantAddress like '%'+@address+'%' or @address='')
	
	group by FB.userRegNo,FB.applicantName,SP.signPersonName,CS.address,FB.isBlocked,FB.deleted	order by FB.applicantName
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetDashBoard]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_GetDashBoard]
as
BEGIN
---Registrants
SELECT     count(distinct BM.FB_ID)_Count, REPLACE(NA.NatureActivity,'(Please Specify)','') _Status,CB.NA_ID
FROM         tn_FormB AS BM INNER JOIN
                      fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID INNER JOIN
                      NatureActivity_Master AS NA ON CB.NA_ID = NA.NA_ID
                      where BM.fb_Approval_Status='Yes' and BM.Status=1 and BM.deleted=0 and CB.deleted=0 and userRegNo is not null
                      group by NA.NatureActivity,CB.NA_ID 
                      order by NA.NatureActivity
                      
---Pending Requests
SELECT     count(distinct BM.FB_ID)_Count, REPLACE(NA.NatureActivity,'(Please Specify)','') _Status,CB.NA_ID
FROM         tn_FormB AS BM INNER JOIN
                      fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID INNER JOIN
                      NatureActivity_Master AS NA ON CB.NA_ID = NA.NA_ID
                      where BM.fb_HardCopy_Rcv='No' and BM.tempRegNo is not null and BM.Status=1 and BM.deleted=0 and CB.deleted=0 
                      group by NA.NatureActivity,CB.NA_ID 
                      order by NA.NatureActivity
                      
--Application Status
select 1 SN,'Registrant'_Status,COUNT(*)_Count,'ViewRegistrans.aspx'Url from tn_FormB where fb_Approval_Status='Yes' and Status=1 and deleted=0 and userRegNo is not null
union
select 2 SN,'In-complete Applications'_Status,COUNT(*)_Count,'DashboardDetails.aspx?mt=incApp&dt=hflrj634h87ksf797jaef78979klajsd8oj'Url from tn_FormB where tempRegNo is null and Status=1 and deleted=0
union
select 3 SN,'Verification Pending'_Status,COUNT(*)_Count,'ViewApplicants.aspx?mt=varPen&dt=hflrj634h87ksf797jaef78979klajsd8oj'Url from tn_FormB where fb_HardCopy_Rcv='No' 
and tempRegNo is not null and Status=1 and deleted=0
union
select 4 SN,'Pending Approval'_Status,COUNT(*)_Count,'ViewApplicants.aspx?mt=ApprPen&dt=hflrj634h87ksf797jaef78979klajsd8oj'Url from tn_FormB where fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' 
 and Status=1 and deleted=0

--State-wise Registration Status
select SM.S_ID,SM.StateName,
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and S_ID=SM.S_ID and Status=1 and deleted=0)Reg_Count,
(select COUNT(*) from tn_FormB where tempRegNo is null and S_ID=SM.S_ID and Status=1 and deleted=0)In_Count,
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='No'and tempRegNo is not null and S_ID=SM.S_ID and Status=1 and deleted=0)Var_Count,
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' and S_ID=SM.S_ID and Status=1 and deleted=0)Appr_Count
 from State_Master SM 
--where SM.Status=1 and SM.Deleted=0
order by SM.StateName

--Zone-wise Registration Status
select ZM.ZO_ID,ZM.ZonalOffice,
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0)Reg_Count,
(select COUNT(*) from tn_FormB where tempRegNo is null and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0)In_Count,
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='No'and tempRegNo is not null and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0)Var_Count,
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0)Appr_Count

 from ZonalOffice_Master ZM
where ZM.Status=1 and ZM.Deleted=0 and ZM.ZO_ID in (select distinct ZO_ID from tn_FormB where Status=1 and deleted=0)
order by ZM.ZonalOffice

--Substance-wise Registration Status
select CS.CS_ID,CS.ControlledSubstance,
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID 
WHERE BM.fb_Approval_Status = 'Yes' AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0)Reg_Count,
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID
WHERE tempRegNo is null AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0)In_Count,
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID 
WHERE fb_HardCopy_Rcv='No' and tempRegNo is not null AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0)Var_Count,
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID 
WHERE fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0)Appr_Count

 from ControlledSubstance_Master CS
where CS.Status=1 and CS.Deleted=0
order by CS.ControlledSubstance

--Zone-wise Return Filing Status  
Declare @Qtr int
SELECT @Qtr=[DBO].UFN_GetPreviousQuarter()

select ZM.ZO_ID,ZM.ZonalOffice,@Qtr qtr,  
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0)Reg_Count,  
(select COUNT(distinct URN) from(select URNNo URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and FB.ZO_ID=ZM.ZO_ID and returnQuarter>=@Qtr UNION ALL select URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=ZM.ZO_ID and Quater>=@Qtr)ds)ReturnFiled,
(select COUNT(distinct URNNo) URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and FB.ZO_ID=ZM.ZO_ID and returnQuarter>=@Qtr)FiledFE,
(select COUNT(distinct URN)URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=ZM.ZO_ID and Quater>=@Qtr)FiledFF,
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0 and 
userRegNo not in (select distinct URNNo URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and 
FB.ZO_ID=ZM.ZO_ID and returnQuarter>=@Qtr 
UNION ALL select distinct URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=ZM.ZO_ID and 
Quater>=@Qtr))NotFiled
--(select COUNT(distinct URN) from(select URNNo URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and FB.ZO_ID=ZM.ZO_ID and returnQuarter<@Qtr UNION ALL select URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=ZM.ZO_ID and Quater<@Qtr)ds)NotFiled  
--(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0))Appr_Count  
  
from ZonalOffice_Master ZM where ZM.Status=1 and ZM.Deleted=0 order by ZM.ZonalOffice

UPDATE tn_formB SET deleted=1,deleteBy=1,deleteDate=GETDATE() where stepcomplete<=5 and DATEDIFF(HOUR,addDate,GETDATE())>48 and isSubmitted=0 and IsReassigned=0
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetDashBoard_ZoneWise]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GetDashBoard_ZoneWise]
( 
@ZO_ID int
) 
as  
BEGIN  
---Registrants  
SELECT     count(distinct BM.FB_ID)_Count, REPLACE(NA.NatureActivity,'(Please Specify)','') _Status,CB.NA_ID  
FROM         tn_FormB AS BM INNER JOIN  
                      fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID INNER JOIN  
                      NatureActivity_Master AS NA ON CB.NA_ID = NA.NA_ID  
                      where BM.fb_Approval_Status='Yes' and BM.Status=1 and BM.deleted=0 and CB.deleted=0 and userRegNo is not null and ISNULL(BM.IsBlocked,0)=0 and BM.ZO_ID=@ZO_ID 
                      group by NA.NatureActivity,CB.NA_ID   
                      order by NA.NatureActivity  
                        
---Pending Requests  
SELECT     count(distinct BM.FB_ID)_Count, REPLACE(NA.NatureActivity,'(Please Specify)','') _Status,CB.NA_ID  
FROM         tn_FormB AS BM INNER JOIN  
                      fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID INNER JOIN  
                      NatureActivity_Master AS NA ON CB.NA_ID = NA.NA_ID  
                      where BM.fb_HardCopy_Rcv='No' and BM.tempRegNo is not null and BM.Status=1 and BM.deleted=0 and CB.deleted=0 and ISNULL(BM.IsBlocked,0)=0 and BM.ZO_ID=@ZO_ID  
                      group by NA.NatureActivity,CB.NA_ID   
                      order by NA.NatureActivity  
                        
--Application Status  
select 1 SN,'Registrant'_Status,COUNT(*)_Count,'ViewRegistrans.aspx'Url from tn_FormB where fb_Approval_Status='Yes' and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0 and ZO_ID=@ZO_ID  
union  
select 2 SN,'In-complete Applications'_Status,COUNT(*)_Count,'DashboardDetails.aspx?mt=incApp&dt=hflrj634h87ksf797jaef78979klajsd8oj'Url from tn_FormB where tempRegNo is null and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0 and ZO_ID=@ZO_ID  
union  
select 3 SN,'Verification Pending'_Status,COUNT(*)_Count,'ViewApplicants.aspx?mt=varPen&dt=hflrj634h87ksf797jaef78979klajsd8oj'Url from tn_FormB where fb_HardCopy_Rcv='No' and ZO_ID=@ZO_ID and ISNULL(IsBlocked,0)=0  
and tempRegNo is not null and Status=1 and deleted=0  
union  
select 4 SN,'Pending Approval'_Status,COUNT(*)_Count,'ViewApplicants.aspx?mt=ApprPen&dt=hflrj634h87ksf797jaef78979klajsd8oj'Url from tn_FormB where fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' and ZO_ID=@ZO_ID  and ISNULL(IsBlocked,0)=0
 and Status=1 and deleted=0  
  
--State-wise Registration Status  
select SM.S_ID,SM.StateName,  
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and S_ID=SM.S_ID and Status=1 and deleted=0 and ZO_ID=@ZO_ID and ISNULL(IsBlocked,0)=0)Reg_Count,  
(select COUNT(*) from tn_FormB where tempRegNo is null and S_ID=SM.S_ID and Status=1 and deleted=0 and ZO_ID=@ZO_ID and ISNULL(IsBlocked,0)=0)In_Count,  
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='No'and tempRegNo is not null and S_ID=SM.S_ID and Status=1 and deleted=0 and ZO_ID=@ZO_ID and ISNULL(IsBlocked,0)=0)Var_Count,  
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' and S_ID=SM.S_ID and Status=1 and deleted=0 and ZO_ID=@ZO_ID and ISNULL(IsBlocked,0)=0)Appr_Count  
 from State_Master SM  
--where SM.Status=1 and SM.Deleted=0  
order by SM.StateName  
  
--Zone-wise Registration Status  
select ZM.ZO_ID,ZM.ZonalOffice,  
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0)Reg_Count,  
(select COUNT(*) from tn_FormB where tempRegNo is null and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0)In_Count,  
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='No'and tempRegNo is not null and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0)Var_Count,  
(select COUNT(*) from tn_FormB where fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0)Appr_Count  
  
 from ZonalOffice_Master ZM  
where ZM.Status=1 and ZM.Deleted=0 and ZM.ZO_ID=@ZO_ID 
order by ZM.ZonalOffice  
  
--Substance-wise Registration Status  
select CS.CS_ID,CS.ControlledSubstance,  
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN  
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID   
WHERE BM.fb_Approval_Status = 'Yes' AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0 and ZO_ID=@ZO_ID and ISNULL(BM.IsBlocked,0)=0)Reg_Count,  
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN  
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID  
WHERE tempRegNo is null AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0 and ZO_ID=@ZO_ID and ISNULL(BM.IsBlocked,0)=0)In_Count,  
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN  
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID   
WHERE fb_HardCopy_Rcv='No' and tempRegNo is not null AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0 and ZO_ID=@ZO_ID and ISNULL(BM.IsBlocked,0)=0)Var_Count,  
(SELECT COUNT(distinct BM.FB_ID) AS _Count FROM  tn_FormB AS BM INNER JOIN  
 fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID   
WHERE fb_HardCopy_Rcv='Yes' and fb_Approval_Status='No' AND CB.CS_ID=CS.CS_ID AND BM.status = 1 AND BM.deleted = 0 and ZO_ID=@ZO_ID and ISNULL(BM.IsBlocked,0)=0)Appr_Count  
  
 from ControlledSubstance_Master CS  
where CS.Status=1 and CS.Deleted=0  
order by CS.ControlledSubstance  


--Zone-wise Return Filing Status  
Declare @Qtr int
SELECT @Qtr=[DBO].UFN_GetPreviousQuarter()

select ZM.ZO_ID,ZM.ZonalOffice,@Qtr qtr,  
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and ZO_ID=ZM.ZO_ID and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0)Reg_Count,  
(select COUNT(distinct URN) from(select URNNo URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and FB.ZO_ID=ZM.ZO_ID and returnQuarter>=@Qtr UNION ALL select URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=ZM.ZO_ID and Quater>=@Qtr)ds)ReturnFiled,
(select COUNT(distinct URNNo) URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and FB.ZO_ID=ZM.ZO_ID and returnQuarter>=@Qtr)FiledFE,
(select COUNT(distinct URN)URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=ZM.ZO_ID and Quater>=@Qtr)FiledFF,
(select COUNT(*) from tn_FormB where fb_Approval_Status='Yes' and ZO_ID=5 and Status=1 and deleted=0 and ISNULL(IsBlocked,0)=0 and 
userRegNo not in (select distinct URNNo URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and 
FB.ZO_ID=ZM.ZO_ID and returnQuarter>=@Qtr 
UNION ALL select distinct URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=ZM.ZO_ID and 
Quater>=@Qtr))NotFiled
  
from ZonalOffice_Master ZM  
where ZM.Status=1 and ZM.Deleted=0 and ZM.ZO_ID=@ZO_ID 
order by ZM.ZonalOffice  

UPDATE tn_formB SET deleted=1,deleteBy=1,deleteDate=GETDATE() where stepcomplete<=5 and DATEDIFF(HOUR,addDate,GETDATE())>48 and isSubmitted=0 and IsReassigned=0
END  
GO
/****** Object:  StoredProcedure [dbo].[USP_GetDashBoardDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_GetDashBoardDetails]
(    
	@Mode nvarchar(20),    

	@ST_ID int =0,    

	@ZO_ID int =0,

	@Substance varchar(100)='',

	@activity varchar(50)='',

	@SearchCol varchar(20)='',

	@SearchText varchar(100)=''
)    
as    

if(@Mode='Regis')    

begin    
if (@SearchCol='' and @SearchText='')
	begin
		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,S_ID,earlierSurrendered,
		
		(Select COUNT(1) FROM OldURN where OldURN=earlierSurrendered)IsMerged,applicantAddress,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone1,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ1,

		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone2,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ2,

		(select COUNT(distinct premiseAddress) FROM SubURN where FB_ID=UF.FB_ID and deleted=0)NSU

		from UV_RegistrantRecord UF where fb_Approval_Status='Yes' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and (@ST_ID=0 or S_ID=@ST_ID) and IsBlocked=0 and deleted=0

		order by FB_ID desc
		
end
else
begin

		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,S_ID,earlierSurrendered,
		
		(Select COUNT(1) FROM OldURN where OldURN=earlierSurrendered)IsMerged,applicantAddress,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone1,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ1,

		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone2,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ2,

		(select COUNT(distinct premiseAddress) FROM SubURN where FB_ID=UF.FB_ID and deleted=0)NSU

		from UV_RegistrantRecord UF where fb_Approval_Status='Yes' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and (@ST_ID=0 or S_ID=@ST_ID) and IsBlocked=0 and
		
		(case when @SearchCol='URN' then userRegNo when @SearchCol='APC' then applicantName when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID 
		
		when @SearchCol='MBL' then mobileNo when @SearchCol='ST' then StateName when @SearchCol='ZN' then ZonalOffice end) like '%'+@SearchText+'%'            
		
		order by FB_ID desc 
	end
end    

else if(@Mode='varPen')    

begin    
if (@SearchCol='' and @SearchText='')
	begin

		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

		fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,S_ID

		FROM UV_ApplicantList 

		WHERE (deleted = 0) AND (status = 1)AND (tempRegNo is not null) and (fb_HardCopy_Rcv='No') and (@ZO_ID=0 or ZO_ID=@ZO_ID)and (@ST_ID=0 or S_ID=@ST_ID) and IsBlocked=0

		order by FB_ID desc   
end
else
begin

		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

		fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,S_ID

		FROM UV_ApplicantList     

		WHERE (deleted = 0) AND (status = 1)AND (tempRegNo is not null) and (fb_HardCopy_Rcv='No')    

		and (@ZO_ID=0 or ZO_ID=@ZO_ID)and (@ST_ID=0 or S_ID=@ST_ID) and

		(case when @SearchCol='TRN' then tempRegNo when @SearchCol='APC' then applicantName when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID

		when @SearchCol='MBL' then mobileNo when @SearchCol='ST' then StateName when @SearchCol='ZN' then ZonalOffice end) like '%'+@SearchText+'%' and IsBlocked=0

		order by FB_ID desc 
end
end    

else if(@Mode='ApprPen')    

begin    
if (@SearchCol='' and @SearchText='')
	begin

		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

		fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload ,ZO_ID,S_ID

		FROM UV_ApplicantList    

		WHERE (deleted = 0) AND (status = 1)AND (fb_HardCopy_Rcv='Yes') and (fb_Approval_Status='No') and (@ZO_ID=0 or ZO_ID=@ZO_ID)and (@ST_ID=0 or S_ID=@ST_ID) and IsBlocked=0   

		order by FB_ID desc
end
else
begin

		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

		fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,S_ID 

		FROM UV_ApplicantList    

		WHERE (deleted = 0) AND (status = 1)AND (fb_HardCopy_Rcv='Yes') and (fb_Approval_Status='No') and (@ZO_ID=0 or ZO_ID=@ZO_ID)and (@ST_ID=0 or S_ID=@ST_ID) and

		(case when @SearchCol='TRN' then tempRegNo when @SearchCol='APC' then applicantName when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID 

		when @SearchCol='MBL' then mobileNo when @SearchCol='ST' then StateName when @SearchCol='ZN' then ZonalOffice end) like '%'+@SearchText+'%' and IsBlocked=0  

		order by FB_ID desc
end
end    

else if(@Mode='incApp')    

begin    

		SELECT BM.FB_ID,BM.applicantAddress,ZM.ZonalOffice,SM.StateName,BM.userRegNo,BM.addBy, BM.tempRegNo, LM.applicantName, LM.applyingName, LM.emailID, LM.mobileNo, BM.fb_HardCopy_Rcv,     

		BM.fb_Approval_Status, BM.fa_Generate_Status,  AM1.UserName fb_Approval_By, AM2.UserName fa_Generate_By,BM.stepComplete, 

		Case when BM.fb_Approval_Status='Yes' then '~/admin/images/yes-icon.gif' else  '~/admin/images/no-icon.gif' end IUrl,BM.ZO_ID,BM.S_ID      

		FROM         tn_FormB AS BM left JOIN    

							  NCB_LoginMaster AS LM ON BM.addBy = LM.loginID left JOIN    

							  NCB_AdminLoginMaster AS AM1 ON BM.fb_Approval_By = AM1.loginID left JOIN    

							  NCB_AdminLoginMaster AS AM2 ON BM.fa_Generate_By = AM2.loginID left join    

							  State_Master SM ON BM.S_ID=SM.S_ID left join    

							  ZonalOffice_Master ZM ON BM.ZO_ID=ZM.ZO_ID    

		WHERE     (BM.deleted = 0) AND (BM.status = 1)AND (BM.tempRegNo is null)     

		and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID)  

		order by BM.FB_ID desc  

end

if(@Mode='Regss')    

begin    
if (@SearchCol='' and @SearchText='')
	begin

		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID 

		from UV_RegistrantRecord BM left outer join
					  
							  fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID left outer join

							  ControlledSubstance_Master CM ON CS.CS_ID=CM.CS_ID

		WHERE  BM.fb_Approval_Status='Yes' and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID) and (@ST_ID=0 or BM.S_ID=@ST_ID) and CM.ControlledSubstance =@Substance and BM.deleted=0 and IsBlocked=0

		group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID

		order by BM.FB_ID desc    
end
else
begin

		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID 

		from UV_RegistrantRecord BM inner join
					  
							  fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

							  ControlledSubstance_Master CM ON CS.CS_ID=CM.CS_ID   

		WHERE BM.fb_Approval_Status='Yes' and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID) and (@ST_ID=0 or BM.S_ID=@ST_ID) and CM.ControlledSubstance=@Substance and
		
		(case when @SearchCol='URN' then BM.userRegNo when @SearchCol='APC' then BM.applicantName when @SearchCol='APN' then BM.applyingName when @SearchCol='USR' then BM.userID 
		
		when @SearchCol='MBL' then BM.mobileNo when @SearchCol='ST' then BM.StateName when @SearchCol='ZN' then ZonalOffice end) like '%'+@SearchText+'%' and BM.deleted=0 and IsBlocked=0            
		
		group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID

		order by BM.FB_ID desc 
end
end    

else if(@Mode='incss')    

begin    
		SELECT BM.FB_ID,BM.applicantAddress,ZM.ZonalOffice,SM.StateName,BM.userRegNo,BM.addBy, BM.tempRegNo, LM.applicantName, LM.applyingName, LM.emailID, LM.mobileNo, BM.fb_HardCopy_Rcv,     

BM.fb_Approval_Status, BM.fa_Generate_Status,  AM1.UserName, fb_Approval_By, AM2.UserName, fa_Generate_By,BM.stepComplete, 

Case when BM.fb_Approval_Status='Yes' then '~/admin/images/yes-icon.gif' else  '~/admin/images/no-icon.gif' end IUrl      

FROM         tn_FormB AS BM left JOIN    

                      NCB_LoginMaster AS LM ON BM.addBy = LM.loginID left JOIN    

                      NCB_AdminLoginMaster AS AM1 ON BM.fb_Approval_By = AM1.loginID left JOIN    

                      NCB_AdminLoginMaster AS AM2 ON BM.fa_Generate_By = AM2.loginID left join    

                      State_Master SM ON BM.S_ID=SM.S_ID left join    

                      ZonalOffice_Master ZM ON BM.ZO_ID=ZM.ZO_ID inner join
					  
					  fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

					  ControlledSubstance_Master CM ON CS.CS_ID=CM.CS_ID    

WHERE     (BM.deleted = 0) AND (BM.status = 1)AND (BM.tempRegNo is null)     

and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID)  and CM.ControlledSubstance=@Substance
group by BM.FB_ID,BM.applicantAddress,ZM.ZonalOffice,SM.StateName,BM.userRegNo,BM.addBy, BM.tempRegNo, LM.applicantName, LM.applyingName, LM.emailID, LM.mobileNo, BM.fb_HardCopy_Rcv,     

BM.fb_Approval_Status, BM.fa_Generate_Status,  AM1.UserName, fb_Approval_By, AM2.UserName, fa_Generate_By,BM.stepComplete,BM.fb_Approval_Status
order by BM.FB_ID desc  
end

else if(@Mode='varpenss')    

begin    
if (@SearchCol='' and @SearchText='')
	begin
		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

		fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload 

		FROM UV_ApplicantList BM inner join
					  
			 fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

			 ControlledSubstance_Master CM ON CS.CS_ID=CM.CS_ID

		WHERE (BM.deleted = 0) AND (BM.status = 1)AND (BM.tempRegNo is not null) and (BM.fb_HardCopy_Rcv='No')    

				and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID) and CM.ControlledSubstance=@Substance and IsBlocked=0

		group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

				fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload

		order by BM.FB_ID desc   
end
else
begin
		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

				fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload 

		FROM UV_ApplicantList BM inner join
					  
			 fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

			 ControlledSubstance_Master CM ON CS.CS_ID=CM.CS_ID

		WHERE (BM.deleted = 0) AND (BM.status = 1)AND (BM.tempRegNo is not null) and (BM.fb_HardCopy_Rcv='No')    

			 and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID) and CM.ControlledSubstance=@Substance and

			(case when @SearchCol='TRN' then BM.tempRegNo when @SearchCol='APC' then BM.applicantName when @SearchCol='APN' then BM.applyingName when @SearchCol='USR' then BM.userID 

			when @SearchCol='MBL' then BM.mobileNo when @SearchCol='ST' then BM.StateName when @SearchCol='ZN' then BM.ZonalOffice end) like '%'+@SearchText+'%' and IsBlocked=0

		group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

				 fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload

		order by BM.FB_ID desc 
end
end    

else if(@Mode='Apppenss')    

begin    
if (@SearchCol='' and @SearchText='')
	begin
		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

			 fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload 

		FROM UV_ApplicantList BM inner join
					  
			 fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

			 ControlledSubstance_Master CM ON CS.CS_ID=CM.CS_ID   

		WHERE (BM.deleted = 0) AND (BM.status = 1)AND  (BM.fb_HardCopy_Rcv='Yes') and (BM.fb_Approval_Status='No')    

			 and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID) and CM.ControlledSubstance=@Substance and IsBlocked=0   

		group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

			 fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload 

		order by BM.FB_ID desc
end
else
begin
		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

			 fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload 

		FROM UV_ApplicantList BM inner join
					  
			 fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

			 ControlledSubstance_Master CM ON CS.CS_ID=CM.CS_ID   

		WHERE  (BM.deleted = 0) AND (BM.status = 1)AND  (BM.fb_HardCopy_Rcv='Yes') and (BM.fb_Approval_Status='No')    

			 and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID) and CM.ControlledSubstance=@Substance and

			 (case when @SearchCol='TRN' then BM.tempRegNo when @SearchCol='APC' then BM.applicantName when @SearchCol='APN' then BM.applyingName when @SearchCol='USR' then BM.userID 

			 when @SearchCol='MBL' then BM.mobileNo when @SearchCol='ST' then BM.StateName when @SearchCol='ZN' then BM.ZonalOffice end) like '%'+@SearchText+'%' and IsBlocked=0  

		group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

				fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload

		order by BM.FB_ID desc
end
end    


if(@Mode='Regact')    

begin    
if (@SearchCol='' and @SearchText='')
	begin

		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

			fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID 

		from UV_RegistrantRecord BM left outer join
					  
			 fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID left outer join

			 NatureActivity_Master NA ON CS.NA_ID=NA.NA_ID

		WHERE BM.fb_Approval_Status='Yes' and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID) and (@ST_ID=0 or BM.S_ID=@ST_ID) and NA.NatureActivity =@activity and IsBlocked=0

		group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID

order by BM.FB_ID desc    
end
else
begin
		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID 

from UV_RegistrantRecord BM inner join
					  
					  fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

					  NatureActivity_Master NA ON CS.NA_ID=NA.NA_ID

WHERE BM.fb_Approval_Status='Yes' and (@ZO_ID=0 or BM.ZO_ID=@ZO_ID) and (@ST_ID=0 or BM.S_ID=@ST_ID) and NA.NatureActivity =@activity and
		
(case when @SearchCol='URN' then BM.userRegNo when @SearchCol='APC' then BM.applicantName when @SearchCol='APN' then BM.applyingName when @SearchCol='USR' then BM.userID 
		
when @SearchCol='MBL' then BM.mobileNo when @SearchCol='ST' then BM.StateName when @SearchCol='ZN' then ZonalOffice end) like '%'+@SearchText+'%' and IsBlocked=0          
		
group by BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID

order by BM.FB_ID desc 
end
end  

else if(@Mode='penappact')    

begin    
if (@SearchCol='' and @SearchText='')
	begin

		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

		fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID

		FROM UV_ApplicantList BM left outer join
					  
			 fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID inner join

			 NatureActivity_Master NA ON CS.NA_ID=NA.NA_ID

		WHERE (BM.deleted = 0) AND (BM.status = 1)AND (tempRegNo is not null) and (fb_HardCopy_Rcv='No') and NA.NatureActivity =@activity and 
		
		(@ZO_ID=0 or ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID) and IsBlocked=0

		--group by

		order by BM.FB_ID desc   
end
else
begin

		select BM.FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status, fa_Generate_Status, 

		fb_Approval_By, fa_Generate_By,hcRecieved_By,IUrl,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,BM.S_ID

		FROM UV_ApplicantList BM left outer join
					  
			 fb_ControlledSubstanceReg CS ON BM.FB_ID=CS.FB_ID left outer join

			 NatureActivity_Master NA ON CS.NA_ID=NA.NA_ID   

		WHERE (BM.deleted = 0) AND (BM.status = 1)AND (tempRegNo is not null) and (fb_HardCopy_Rcv='No') and NA.NatureActivity =@activity and (@ZO_ID=0 or ZO_ID=@ZO_ID)and (@ST_ID=0 or BM.S_ID=@ST_ID) and

		(case when @SearchCol='TRN' then tempRegNo when @SearchCol='APC' then applicantName when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID

		when @SearchCol='MBL' then mobileNo when @SearchCol='ST' then StateName when @SearchCol='ZN' then ZonalOffice end) like '%'+@SearchText+'%' and IsBlocked=0

		order by BM.FB_ID desc 
end
end   
else if(@Mode='notfilled')
Declare @Qtr int
SELECT @Qtr=[DBO].UFN_GetPreviousQuarter()    
 
	if (@SearchCol='' and @SearchText='')
	begin
		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,S_ID,earlierSurrendered,(Select COUNT(1) FROM OldURN where OldURN=earlierSurrendered)IsMerged,
		
		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone1,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ1,

		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone2,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ2,

		(select COUNT(distinct premiseAddress) FROM SubURN where FB_ID=UV_RegistrantRecord.FB_ID and deleted=0)NSU

		from UV_RegistrantRecord where fb_Approval_Status='Yes' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and (@ST_ID=0 or S_ID=@ST_ID) and IsBlocked=0 and deleted=0 and 
		
		userRegNo not in (select distinct URNNo URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and FB.ZO_ID=UV_RegistrantRecord.ZO_ID and returnQuarter>=@Qtr 
		
		UNION ALL select distinct URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=UV_RegistrantRecord.ZO_ID and Quater>=@Qtr)

		order by FB_ID desc
	end
else
begin
		select FB_ID,ZonalOffice,StateName,userRegNo,addBy,tempRegNo,applicantName,applyingName,emailID,mobileNo,fb_HardCopy_Rcv,fb_Approval_Status,fa_Generate_Status,

		fb_Approval_By,fa_Generate_By,tempRegNo_Date,fb_HardCopy_Rcv_Date,fa_Generate_Date,fb_Approval_Date,dwnload,ZO_ID,S_ID,earlierSurrendered,(Select COUNT(1) FROM OldURN where OldURN=earlierSurrendered)IsMerged,

		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone1,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ1,

		replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(regAnotherZone2,'NA',''),'N/A',''),'N.A.',''),'NOT APPLICABLE',''),'Not Applicable',''),'-',''),'NO',''),'No',''),'--- NA ---',''),'no',''),'Not Any',''),'Nil','')RegZ2,

		(select COUNT(distinct premiseAddress) FROM SubURN where FB_ID=UV_RegistrantRecord.FB_ID and deleted=0)NSU

		from UV_RegistrantRecord where fb_Approval_Status='Yes' and (@ZO_ID=0 or ZO_ID=@ZO_ID) and (@ST_ID=0 or S_ID=@ST_ID) and IsBlocked=0 and 
		
		userRegNo not in (select distinct URNNo URN From tn_FormE FE INNER JOIN tn_FormB FB ON FE.FB_ID=FB.FB_ID where FE.deleted=0 and FB.ZO_ID=UV_RegistrantRecord.ZO_ID and returnQuarter>=@Qtr 
		
		UNION ALL select distinct URN From tn_FormF FF INNER JOIN tn_FormB FB ON FF.URN=FB.userRegNo where FF.deleted=0 and FB.ZO_ID=UV_RegistrantRecord.ZO_ID and Quater>=@Qtr) and
		
		(case when @SearchCol='URN' then userRegNo when @SearchCol='APC' then applicantName when @SearchCol='APN' then applyingName when @SearchCol='USR' then userID 
		
		when @SearchCol='MBL' then mobileNo when @SearchCol='ST' then StateName when @SearchCol='ZN' then ZonalOffice end) like '%'+@SearchText+'%'            
		
		order by FB_ID desc
end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetDistAndCity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_GetDistAndCity]
	@TYPE VARCHAR(10),
	@ID INT
as
	IF @TYPE='DIST'
	BEGIN
	select D_ID,districtName from District_Master where status=1 and deleted=0 AND S_ID=@ID order by districtName
	END
	IF @TYPE='CITY'
	BEGIN
	select C_ID,cityName from City_Master where status=1 and deleted=0 AND D_ID=@ID order by cityName
	END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetDocs]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[USP_GetDocs]
(
	@FB_ID int
)
as

select authorizationLetterDoc as LA,signingPersonPanDoc as SPPC,applicantPanDoc as APPC,certificateIncorporationDoc as CI,
ownershipProofDoc as DP,drugLicenceDoc as DL,importExportCodeDoc as IE,
(select TOP 1 (case when SignPhotoId<>'' then '~/SignPerosn_Id/'+SignPhotoId else '' end) from fb_FurnishDetails where FB_ID=@FB_ID and deleted=0) as SPID 
From tn_FormB where FB_ID=@FB_ID and status=1 and deleted=0
union
select 'Letter-of-Authorization-inFavorof-PersonMakingandSigning-the-Application' as LA,'Making-and-SigningPerson-PanCard' as SPPC,
'PAN-of-the-Applicant' as APPC,'Certificate_Incorporation-PartnershipDeed-AnyOtherInstrumentofRegistrationIssued_by_a_Governmentauthority' as CI,
'DocumentaryProof-of-Ownership-Possession-ofthe-Premises' as DP,'DrugLicence-in-Case-of-an-ApplicantDealing-with-PharmaceuticalSubstances-Preparations' as DL,
'ImportExportCode-in-Case-of-an-Importer-Exporter' as IE,'Partnership-PanId' as SPID


declare @return varchar(2000)
select @return=COALESCE(@return,'')+signPhotoID+', ' from fb_SigningPersonDetails where deleted=0 and FB_ID=@FB_ID and signPhotoID<>''
select @return as SP_Id
GO
/****** Object:  StoredProcedure [dbo].[USP_GetDocuments]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_GetDocuments]
(
	@FB_ID int,
	@Form varchar(5)
)
as

	if @Form='B'
	begin
		select ad.docId,ad.description,al.UserName,CONVERT(varchar(20),ad.addDate,107)addDate,fb.tempRegNo,fb.applicantName
		from FormB_AddtionalDoc ad inner join 
		NCB_AdminLoginMaster al ON ad.addBy=al.loginID inner join
		tn_FormB fb ON ad.FB_ID=fb.FB_ID 
		where ad.deleted=0 and ad.FB_ID=@FB_ID
	end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetFBDetails4FF]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[USP_GetFBDetails4FF]   
(  
@loginID int  
)  
as  
BEGIN  
SELECT FB.applicantName, FB.userRegNo, CS.ControlledSubstance, C_CS.CS_ID, FB.pincode, FB.S_ID, FB.cityName, FB.applicantAddress  

FROM tn_FormB AS FB INNER JOIN fb_ControlledSubstanceReg AS C_CS ON FB.FB_ID = C_CS.FB_ID INNER JOIN ControlledSubstance_Master AS CS ON C_CS.CS_ID = CS.CS_ID  

WHERE (FB.addBy = @loginID) AND (FB.deleted = 0) ORDER BY CS.ControlledSubstance  
  
 if exists(select * from tn_FormF where addBy=@LoginID and deleted=0)
 begin
	if exists(select * from Quarter_ReturnFiling where URN=(select userRegNo from tn_FormB where addBy=@loginID and deleted=0))
	BEGIN
		select [quarter] Qtr_ID from Quarter_ReturnFiling where URN=(select userRegNo from tn_FormB where addBy=@loginID and deleted=0)
	END
	ELSE
	BEGIN
		select TOP 1 Quater+1 as Qtr_ID from tn_FormF where addBy=@LoginID and deleted=0 order by FF_ID DESC    
    END
 end    
 else    
  begin  
  declare @Qtr_Name varchar(50)  
  --select @Qtr_Name='Quarter'+cast(case when qtr='4' then 1 else qtr+1 end as varchar)+' '+  
  --cast(case when qtr='4' then returnyear+1 else returnyear end as varchar)
   select @Qtr_Name='Q'+cast(qtr as varchar)+' '+ cast(returnyear as varchar)+' - '+
   CAst(case when qtr=1 then 'Jan-March' when qtr=2 then 'April-June' when qtr=3 then 'July-Sept' when qtr=4 then 'Oct-Dec' else '' end as varchar)    
  from  
  (  
  select (case when DATEPART(month,userRegNo_IssueDT) between 1 and 3 then 1   
     when DATEPART(month,userRegNo_IssueDT)between 4 and 6 then 2  
     when DATEPART(month,userRegNo_IssueDT)between 7 and 9 then 3  
     when DATEPART(month,userRegNo_IssueDT)between 10 and 12 then 4 else '' end)qtr,  
     DATEPART(YEAR,userRegNo_IssueDT)returnyear  
  from tn_FormB where addBy=@LoginID and deleted=0  
  )tmp;  
  select Qtr_ID from Quater_Master where Qtr_Name=@Qtr_Name  
 end
   
 select (case when DATEPART(month,GETDATE()) between 1 and 3 then 1     
     when DATEPART(month,GETDATE())between 4 and 6 then 2    
     when DATEPART(month,GETDATE())between 7 and 9 then 3    
     when DATEPART(month,GETDATE())between 10 and 12 then 4 else '' end)CurrentQuarter  

END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetFormBDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_GetFormBDetails]
(    
 @FB_ID int,    
 @Page int    
)    
as    
if @Page = 1    
begin    
 select applicantName,regAnotherZone1,regAnotherZone2,earlierSurrendered,ZO_ID    
 from tn_FormB where FB_ID=@FB_ID and deleted=0    
     
 --SELECT premisesAddress as Col1,PT_ID as Col2,ON_ID as Col3,commissionate as Col4,division as Col5,range as Col6,    
 --address as Col7,contactDetails as Col8,CS_ID as Col9,NA_ID as Col10,otherPremises as Col11,otherOccupationNature as Col12    
 --FROM fb_ControlledSubstanceReg    
 --    where FB_ID=@FB_ID and deleted=0
 
 SELECT premisesAddress,PT_ID,ON_ID,commissionate,division,range,address,contactDetails,CS_ID,
 dbo.ufn_GetActivity(@FB_ID,premisesAddress)NA_ID,otherPremises,otherOccupationNature 
 FROM fb_ControlledSubstanceReg where FB_ID=@FB_ID and deleted=0
 group by premisesAddress,PT_ID,ON_ID,commissionate,division,range,address,NA_ID,
 contactDetails,CS_ID,otherPremises,otherOccupationNature,PD_ID
 order by PD_ID

 SELECT premisesAddress Col1,PT_ID Col2,ON_ID Col3,commissionate Col4,division Col5,range Col6,address Col7,contactDetails Col8,CS_ID Col9,
 '' Col13,'' Col14,dbo.ufn_GetActivity(@FB_ID,premisesAddress)NA_ID,dbo.ufn_GetSubActivity(@FB_ID,premisesAddress,CS_ID)S_NA_ID,
 dbo.ufn_GetSubSubActivity(@FB_ID,premisesAddress,CS_ID)SS_NA_ID,dbo.ufn_GetActivity(@FB_ID,premisesAddress)Col10,otherPremises Col11,
 otherOccupationNature  Col12,S_ID Col15,D_ID Col16,C_ID Col17,pinCode Col18,OthersNA Col19,dbo.ufn_GetSubActivity(@FB_ID,premisesAddress,CS_ID)Col20,
 dbo.ufn_GetSubSubActivity(@FB_ID,premisesAddress,CS_ID)Col21,(select Others from fb_ControlledSubstance_SubNatureActivity where premisesAddress=S.premisesAddress and CS_ID=S.CS_ID and FB_ID=@FB_ID and S_NA_ID=3 and deleted=0)Col22
 FROM fb_ControlledSubstanceReg S where FB_ID=@FB_ID and deleted=0
 group by premisesAddress,PT_ID,ON_ID,commissionate,division,range,address,contactDetails,CS_ID,otherPremises,
 otherOccupationNature,dbo.ufn_GetActivity(@FB_ID,premisesAddress),S_ID,D_ID,C_ID,pinCode,OthersNA
 --order by PD_ID
end    
  
if @Page = 2  
begin  
 select CS_ID as Col1,case prodCapacity1 when '0.0' then null else prodCapacity1 end as Col2,  
 case prodCapacity2 when '0.0' then null else prodCapacity2 end as Col3,  
 case prodCapacity3 when '0.0' then null else prodCapacity3 end as Col4,mfdYear1 as Col5,  
 case mfdQTY1 when '0.0' then null else mfdQTY1 end as Col6,mfdYear2 as Col7,  
 case mfdQTY2 when '0.0' then null else mfdQTY2 end as Col8,mfdYear3 as Col9,  
 case mfdQTY3 when '0.0' then null else mfdQTY3 end as Col10,rawMaterials1 as Col11,rawMaterials2 as Col12,  
 rawMaterials3 as Col13,MFD_ID as Col14   
 from fb_ManufactureInfo   
 where FB_ID=@FB_ID and deleted=0  
   
 select CS_ID as Col1,description as Col2,rawMaterials1 as Col3,rawMaterials2 as Col4,rawMaterials3 as Col5,  
 case consumptionCapacity1 when '0.0' then null else consumptionCapacity1 end as Col6,  
 case consumptionCapacity2 when '0.0' then null else consumptionCapacity2 end as Col7,  
 case consumptionCapacity3 when '0.0' then null else consumptionCapacity3 end as Col8,consumedYear1 as Col9,  
 case consumedQTY1 when '0.0' then null else consumedQTY1 end as Col10,consumedYear2 as Col11,  
 case consumedQTY2 when '0.0' then null else consumedQTY2 end as Col12,consumedYear3 as Col13,  
 case consumedQTY3 when '0.0' then null else consumedQTY3 end as Col14  
 from fb_ConsumptionInfo   
 where FB_ID=@FB_ID and deleted=0  
end

if @Page = 3
begin
select applicantName,applicantAddress,cityName,pincode,S_ID,mobileNo,telephoneNo,faxNo,emailId,panNo,applicantName_Pan,
panApplied,panApplyProof,businessConstitution from tn_FormB 
where FB_ID=@FB_ID and deleted=0  

select signPersonName as Col1,Desig_ID as Col2,signPersonAddress as Col3,signCity as Col4,signPincode as Col5,
S_ID as Col6,signMobileNo as Col7,signTelNo as Col8,signFaxNo as Col9,signEmailId as Col10,signPanNo as Col11,
signPendingCases as Col12,signPendingCasesDetails as Col13,signPhotoID as Col14,SP_ID as Col16 from fb_SigningPersonDetails
where FB_ID=@FB_ID and deleted=0  

end

if @Page = 4
begin
	select departName,businessTransNo,validityUpto from fb_BusinessTransactions
	where FB_ID=@FB_ID and deleted=0  
end
if @Page = 5
begin
	
	select conviction_PendingCases,orderDetails,declarationName,convert(varchar,declareDate,103)declareDate,declarePlace, 
	authorizationLetterDoc,signingPersonPanDoc,applicantPanDoc,certificateIncorporationDoc,ownershipProofDoc,drugLicenceDoc,importExportCodeDoc
	from tn_FormB where FB_ID=@FB_ID and deleted=0 

end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetFormDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_GetFormDetails]            
(            
 @ID int,            
 @Form varchar(1)            
)            
as            
if @Form='E'            
begin            
 select qm.Qtr_Name,fe.urnNo,fe.manufacturerName,fe.address,fe.city,fe.pincode,fe.returnFilled,            
 fe.reasonDelaySubmission,fe.name,fe.designation,CONVERT(varchar(15),fe.declarationDate,103)declarationDate,sm.StateName             
 from tn_formE fe inner join Quater_Master qm ON fe.returnQuarter=qm.Qtr_ID             
 inner join State_Master sm ON fe.S_ID=sm.S_ID            
 where fe.FE_ID=@ID            
             
 select cs.ControlledSubstance,CONVERT(varchar(15),mfdDate,103)mfdDate,mfdQauntity            
 from fe_SubStanceDetails csd inner join             
 ControlledSubstance_Master cs on csd.CS_ID=cs.CS_ID             
 left outer join fe_ManufactureDetails md ON csd.FED_ID=md.FED_ID            
 where csd.FE_ID=@ID and csd.deleted=0 and md.mfdQauntity is not null            
             
 select cs.ControlledSubstance,CONVERT(varchar(15),saleDate,103)saleDate,urnNo,personName,    
 personAddress,consignNo,consignQTY,nocNo            
 from fe_SubStanceDetails csd inner join             
 ControlledSubstance_Master cs on csd.CS_ID=cs.CS_ID             
 left outer join fe_SaleDetails sd ON csd.FED_ID=sd.FED_ID            
 where csd.FE_ID=@ID and csd.deleted=0 and sd.consignQTY is not null            
             
 select cs.ControlledSubstance,csd.openingBalance,csd.closingBalance            
 from fe_SubStanceDetails csd inner join             
 ControlledSubstance_Master cs on csd.CS_ID=cs.CS_ID             
 where csd.FE_ID=@ID and csd.deleted=0            
end          
 if @Form='F'            
begin           
 select qm.Qtr_Name,ff.URN,ff.Seller_Name,ff.address,ff.City_Name,ff.pincode,ff.ISWithinDueDT,Details_Type,            
 ff.name,ff.Designation,CONVERT(varchar(15),ff.Sign_DT,103)Sign_DT,sm.StateName             
 from tn_FormF  ff inner join Quater_Master qm ON ff.Quater=qm.Qtr_ID             
 inner join State_Master sm ON ff.State_ID=sm.S_ID            
 where ff.FF_ID =@ID and ff.deleted =0          
select CM.ControlledSubstance ,OP_Balance,Convert (varchar (15),OP_Date,103)OP_Date,URN,  
Category,Reciever, Reciever_Add,Consignment,Quantity_Received,Total,CL_Balance,Quantity_Received, nocNo           
from ff_Receipt_Import ffRI inner join ControlledSubstance_Master CM on           
CM.CS_ID= ffRI.CS_ID where ffRI.FF_ID = @ID  and ffRI.Deleted =0   and Category=1 
select CM.ControlledSubstance ,OP_Balance,Convert (varchar (15),OP_Date,103)OP_Date,URN,  
Category,Reciever, Reciever_Add,Consignment,Quantity_Received,Total,CL_Balance,Quantity_Received, nocNo           
from ff_Receipt_Import ffRI inner join ControlledSubstance_Master CM on           
CM.CS_ID= ffRI.CS_ID where ffRI.FF_ID = @ID  and ffRI.Deleted =0   and Category=2 
select CM.ControlledSubstance ,OP_Balance,Convert (varchar (15),OP_Date,103)OP_Date,URN,  
Category,Reciever, Reciever_Add,Consignment,Quantity_Received,Total,CL_Balance,Quantity_Received, nocNo           
from ff_Receipt_Import ffRI inner join ControlledSubstance_Master CM on           
CM.CS_ID= ffRI.CS_ID where ffRI.FF_ID = @ID  and ffRI.Deleted =0   and Category=3     
 end        
 if @Form ='G'        
 begin        
 select fg.regNoConsignor ,fg.nameConsignor,fg.nameConsignee,fg.addressConsignor,fg.cityConsignor,sm.StateName,        
 fg.pincodeConsignor,fg.nameConsignerMan,fg.nameConsignee,fg.transportMode        
 from tn_FormG fg inner join State_Master sm ON fg.stateIdConsignor=sm.S_ID        
 where fg.FG_Id=@ID and fg.deleted =0        
 select fgc.name,CS.ControlledSubstance ,URN,CONVERT(varchar (15),sentDate,103)sentDate,fgc.name,fgc.address,fgc.noOfPackage,fgc.quantity from tnFormG_ConsignmentDesc fgc inner join             
 ControlledSubstance_Master cs on fgc.CS_ID=cs.CS_ID where fgc.FG_Id = @ID         
 end      
       
 if @Form ='H'        
 begin        
 select fh.FH_ID,fh.URN,fh.consignor_Name,fh.Address,fh.Name,fh.Designation, fh.Quater,      
 Convert(varchar(15),fh.Sign_DT,103)Sign_DT,qm.Qtr_Name      
 from tn_FormH fh inner join Quater_Master qm ON fh.Quater=qm.Qtr_ID       
 where fh.deleted=0 and fh.FH_ID=@ID      
       
 select cs.ControlledSubstance,Convert(varchar(15),cd.Sent_Date,107)Sent_Date,cd.URN,cd.Quantity,      
 cd.Name,cd.Sent_Address,cd.ConsignmentNo,cd.Transport_Mode,cd.transportNo,      
 (case when cd.Transport_Mode='By Road' then 'Vehicle No'      
 when cd.Transport_Mode='By Rail' then 'RR No'      
 when cd.Transport_Mode='By Sea' then 'Bill of Lading No'      
 when cd.Transport_Mode='By Air' then 'AWB No'      
 else '' end)Refno      
 from dbo.fh_consignments_details cd inner join ControlledSubstance_Master cs ON cd.CS_ID=cs.CS_ID      
 where cd.FH_ID=@ID and cd.Deleted=0      
 end      
      
 if @Form ='I'      
 begin      
 select fb.userRegNo, fi.applicantName,address,city,fi.pincode,place,name,designation,sm .StateName,CONVERT (varchar (15),date,103)date       
 from tn_FormI fi inner join State_Master sm ON fi.stateId=sm.S_ID       
 inner join   tn_FormB fb on fi.addBy= fb.addBy      
  where fi.FI_Id =@ID and fi.deleted=0      
  select fisc.destroyedQty,fisc.typeOfPackage,fisc.storagePlace,fisc.reasons,fisc.manner,      
  fisc.appearQty,fisc.returnFiledQty,cs.ControlledSubstance from tn_FormI_SubstanceCotrolled fisc inner join             
 ControlledSubstance_Master cs on fisc.CS_ID=cs.CS_ID where fisc.FI_Id =@ID      
 end
 
GO
/****** Object:  StoredProcedure [dbo].[USP_GetFormDetails_URN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_GetFormDetails_URN]
(
	@Form varchar(1),
	@URN varchar(11),
	@Quarter varchar(20)
)
as
if @Form='E'
begin
	select FE_ID from tn_FormE fe inner join Quater_Master qm ON fe.returnQuarter=qm.Qtr_ID
	where urnNo=@URN and qm.Qtr_Name=@Quarter
end
if @Form='F'
begin
	select FF_ID from tn_FormF fe inner join Quater_Master qm ON fe.Quater=qm.Qtr_ID
	where URN=@URN and qm.Qtr_Name=@Quarter
end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetFormE]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[USP_GetFormE]
(    
 @LoginID int    
)    
as    
 declare @FB_ID int  
 
 select @FB_ID=FB_ID from tn_FormB where addBy=@LoginID and deleted=0   

 select FB_ID,applicantName,applicantAddress,cityName,pincode,S_ID,userRegNo from tn_FormB where addBy=@LoginID and deleted=0    
   
 select cs.ControlledSubstance,csr.CS_ID from ControlledSubstance_Master cs inner join fb_ControlledSubstanceReg csr ON cs.CS_ID=csr.CS_ID   
 where csr.FB_ID=@FB_ID and NA_ID=1 group by cs.ControlledSubstance,csr.CS_ID  
   
 if exists(select * from tn_FormE where FB_ID=@FB_ID and deleted=0)    
 begin    
 select TOP 1 returnQuarter+1 as Qtr_ID from tn_FormE where FB_ID=@FB_ID order by FE_ID DESC    
     
 end    
 else    
 begin    
  declare @Qtr_Name varchar(50)    
  --select @Qtr_Name='Quarter'+cast(case when qtr='4' then 1 else qtr+1 end as varchar)+' '+    
  --cast(case when qtr='4' then returnyear+1 else returnyear end as varchar)  
   select @Qtr_Name='Q'+cast(qtr as varchar)+' '+ cast(returnyear as varchar)+' - '+  
   CAst(case when qtr=1 then 'Jan-March' when qtr=2 then 'April-June' when qtr=3 then 'July-Sept' when qtr=4 then 'Oct-Dec' else '' end as varchar)      
  from    
  (    
  select (case when DATEPART(month,userRegNo_IssueDT) between 1 and 3 then 1     
     when DATEPART(month,userRegNo_IssueDT)between 4 and 6 then 2    
     when DATEPART(month,userRegNo_IssueDT)between 7 and 9 then 3    
     when DATEPART(month,userRegNo_IssueDT)between 10 and 12 then 4 else '' end)qtr,    
     DATEPART(YEAR,userRegNo_IssueDT)returnyear    
  from tn_FormB where addBy=@LoginID and deleted=0    
  )tmp;    
  select Qtr_ID from Quater_Master where Qtr_Name=@Qtr_Name    
 end  
   
 select (case when DATEPART(month,GETDATE()) between 1 and 3 then 1     
     when DATEPART(month,GETDATE())between 4 and 6 then 2    
     when DATEPART(month,GETDATE())between 7 and 9 then 3    
     when DATEPART(month,GETDATE())between 10 and 12 then 4 else '' end)CurrentQuarter  
       
if EXISTS(SELECT * from fb_ControlledSubstanceReg where NA_ID=7)
BEGIN
	declare @quarter int
	select Top 1 @quarter=returnQuarter from tn_FormE where FB_ID=@FB_ID order by FE_ID DESC
	if exists(SELECT * from tn_FormF F INNER JOIN ff_Receipt_Import R ON F.FF_ID=R.FF_ID where F.Quater=@quarter and F.loginID=@LoginID and R.Category=3)
	BEGIN
		SELECT TOP 1 CL_Balance closingBalance from tn_FormF F INNER JOIN ff_Receipt_Import R ON F.FF_ID=R.FF_ID where F.Quater=@quarter and F.loginID=@LoginID and R.Category=3 order by FD_ID DESC
	END
	ELSE
	BEGIN
		select 0 closingBalance
	END
END
ELSE
BEGIN
	select closingBalance from fe_SubStanceDetails   
 where FE_ID=(select Top 1 FE_ID from tn_FormE where FB_ID=@FB_ID order by FE_ID DESC) and deleted=0  
END

   
select case when Convert(varchar(15),DATEADD(month,1,Qtr_EndDate),101) > COnvert(varchar(15),getdate(),101) then 'Yes' else 'No' end as FilingMsg from Quater_Master   
where Qtr_ID=(select TOP 1 returnQuarter+1 as Qtr_ID from tn_FormE where FB_ID=@FB_ID order by FE_ID DESC) 


 select cs.ControlledSubstance,csr.CS_ID from ControlledSubstance_Master cs     
 inner join fb_ControlledSubstanceReg csr ON cs.CS_ID=csr.CS_ID   
 where csr.FB_ID=@FB_ID and NA_ID=7 group by cs.ControlledSubstance,csr.CS_ID 


 
GO
/****** Object:  StoredProcedure [dbo].[USP_GetFormGData]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GetFormGData]
(
@loginId int,
@consigneeReg varchar(50) = null,
@action varchar(250)
)
	
AS
BEGIN
	if(@action= 'MainData')
	begin
		select top 1 * from tn_FormB where addBy = @loginId and deleted = 0
		select  CS_ID, ControlledSubstance from ControlledSubstance_Master
		select Qtr_ID, Qtr_Name from Quater_Master where deleted = 0 and status = 1
	end
	
	else if(@action= 'ConsigneeData')
	begin
		select top 1 * from tn_FormB where addBy <> @loginId and userRegNo = @consigneeReg and deleted = 0 and ZO_ID in (select ZO_ID from tn_FormB 
		where addBy = @loginId) 
	end
	
END

GO
/****** Object:  StoredProcedure [dbo].[USP_GetFormH]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[USP_GetFormH] 
(  
 @LoginID int  
)  
as  
 declare @FB_ID int  
 select @FB_ID=FB_ID from tn_FormB where addBy=@LoginID and deleted=0  
 select FB_ID,applicantName,applicantAddress,cityName,pincode,S_ID,userRegNo from tn_FormB where addBy=@LoginID and deleted=0  
 
 select cs.ControlledSubstance,csr.CS_ID
 from ControlledSubstance_Master cs   
 inner join fb_ControlledSubstanceReg csr ON cs.CS_ID=csr.CS_ID 
 where csr.FB_ID=@FB_ID
 
 if exists(select * from tn_FormH where addBy=@LoginID and deleted=0)  
 begin  
 select TOP 1 Quater+1 as Qtr_ID from tn_FormH where addBy=@LoginID order by FH_ID DESC  
   
 end  
 else  
  begin  
  declare @Qtr_Name varchar(50)  
  --select @Qtr_Name='Quarter'+cast(case when qtr='4' then 1 else qtr+1 end as varchar)+' '+  
  --cast(case when qtr='4' then returnyear+1 else returnyear end as varchar)
   select @Qtr_Name='Q'+cast(qtr as varchar)+' '+ cast(returnyear as varchar)+' - '+
   CAst(case when qtr=1 then 'Jan-March' when qtr=2 then 'April-June' when qtr=3 then 'July-Sept' when qtr=4 then 'Oct-Dec' else '' end as varchar)    
  from  
  (  
  select (case when DATEPART(month,userRegNo_IssueDT) between 1 and 3 then 1   
     when DATEPART(month,userRegNo_IssueDT)between 4 and 6 then 2  
     when DATEPART(month,userRegNo_IssueDT)between 7 and 9 then 3  
     when DATEPART(month,userRegNo_IssueDT)between 10 and 12 then 4 else '' end)qtr,  
     DATEPART(YEAR,userRegNo_IssueDT)returnyear  
  from tn_FormB where addBy=@LoginID and deleted=0  
  )tmp;  
  select Qtr_ID from Quater_Master where Qtr_Name=@Qtr_Name  
 end
 select (case when DATEPART(month,GETDATE()) between 1 and 3 then 1   
     when DATEPART(month,GETDATE())between 4 and 6 then 2  
     when DATEPART(month,GETDATE())between 7 and 9 then 3  
     when DATEPART(month,GETDATE())between 10 and 12 then 4 else '' end)CurrentQuarter
     
     
GO
/****** Object:  StoredProcedure [dbo].[USP_GetFormId]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_GetFormId] 
(  
@urn varchar(15),
@quarter int,
@formName varchar(50) 
)  
as 
begin
	if(@formName = 'H')
	begin
		select top 1 FH_ID from tn_FormH where URN = @urn and Quater = @quarter and deleted = 0
	end

end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetHistoryUrnWise]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PRoc [dbo].[USP_GetHistoryUrnWise]   
(      
 @action varchar(250),  
 @urn varchar(50),  
 @ZO_ID int,  
 @CS_Id int = null  
)      
as   
begin  
 if(@action = 'History')  
 begin  
   
 if(@ZO_ID = 0)  
 begin  
 select trn.date, cs.ControlledSubstance, trn.type, trn.urn2, trn.qty, isnull((select Qtr_Name from Quater_Master where Qtr_ID = trn.quarter   
 and deleted = 0), '')as Quarter,trn.quarter qtrId  
  
 from VW_TransactionLoginWise trn inner join tn_FormB fb on trn.login = fb.addBy inner join ControlledSubstance_Master cs on  
 trn.CS_ID = cs.CS_ID   
   
 where trn.URN = @urn and trn.CS_ID = @CS_Id and fb.deleted = 0 order by cs.ControlledSubstance asc, trn.date asc  
   
 end  
 else if(@ZO_ID > 0)  
 begin  
 select trn.date, cs.ControlledSubstance, trn.type, trn.urn2, trn.qty, isnull((select Qtr_Name from Quater_Master where Qtr_ID = trn.quarter   
 and deleted = 0), '')as Quarter,trn.quarter qtrId   
  
 from VW_TransactionLoginWise trn inner join tn_FormB fb on trn.login = fb.addBy inner join ControlledSubstance_Master cs on  
 trn.CS_ID = cs.CS_ID   
   
 where trn.URN = @urn and trn.ZO_ID = @ZO_ID and trn.CS_ID = @CS_Id and fb.deleted = 0 order by cs.ControlledSubstance asc, trn.date asc  
   
 end  
   
 end  
   
 else if(@action = 'Substance')  
 begin  
  if(@ZO_ID = 0)  
  begin  
   
  select CS_ID, urn, (select ControlledSubstance from ControlledSubstance_Master where CS_ID = VW_TransactionLoginWise.CS_ID)as ControlledSubstance,  
  (select FB_ID from tn_FormB where userRegNo = URN)as FB_ID  
  from VW_TransactionLoginWise where URN = @urn group by CS_ID, urn  
    
  end  
  else if(@ZO_ID > 0)  
  begin  
   select CS_ID, urn, (select ControlledSubstance from ControlledSubstance_Master where CS_ID = VW_TransactionLoginWise.CS_ID)as ControlledSubstance,  
   (select FB_ID from tn_FormB where userRegNo = URN)as FB_ID  
   from VW_TransactionLoginWise where URN = @urn and zo_id = @ZO_ID group by CS_ID, urn  
  end  
    
 end  
   
end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetMasterTableData]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_GetMasterTableData]
as
BEGIN
	select CS_ID,ControlledSubstance from ControlledSubstance_Master(Nolock) where Status=1 and Deleted=0 order by ControlledSubstance
	
	select NA_ID,NatureActivity from NatureActivity_Master(Nolock) where Status=1 and Deleted=0 order by displayOrder
	
	select ON_ID,PremisesOccupation from OccupationNature_Master(Nolock) where Status=1 and Deleted=0
	
	select PT_ID,PremisesType from PremisesType_Master(Nolock) where Status=1 and Deleted=0
	
	select ZO_ID,ZonalOffice from ZonalOffice_Master(Nolock) where Status=1 and Deleted=0 order by ZonalOffice
	
	select S_ID,StateName from State_Master(Nolock) where Status=1 and Deleted=0 order by StateName
	
	select MFD_ID,ManufacturedFor from ManufacturedFor(Nolock) where Status=1 and Deleted=0 order by ManufacturedFor
	
	select Desig_ID,desigName from Designation_Master(Nolock) where Status=1 and Deleted=0 order by desigName
	
	select S_ID,D_ID,districtName from District_Master(Nolock) where status=1 and deleted=0 order by districtName
	
	select D_ID,C_ID,cityName from City_Master(Nolock) where status=1 and deleted=0 order by cityName

	select S_NA_ID,SubActivity from Sub_NatureActivity_Master(Nolock) where status=1 and deleted=0 order by SubActivity

	select S_NA_ID,SubSubActivity from SubSub_NatureActivity_Master(Nolock) where status=1 and deleted=0 order by SubSubActivity
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetQuarterComparativeReport]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_GetQuarterComparativeReport]
(
	@urn1 varchar(11),
	@urn2 varchar(11),
	@substance varchar(100),
	@zone_id int=0,
	@form varchar(1)
)
as
if @form='E'
begin
Select soldURN1,soldURN2,ControlledSubstance,saleQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
Seller_Name,manufacturerName,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,Buyer_Name1,Buyer_Name2,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2 from
(
Select soldURN1,soldURN2,ControlledSubstance,saleQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
Seller_Name,manufacturerName,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,Buyer_Name1,Buyer_Name2,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2 
from UV_ComparativeReportQuarterFormE 
where soldURN1=@urn1 and soldURN2=@urn2 and ControlledSubstance=@substance and 
(@zone_id=0 or (BuyerZone1=@zone_id or BuyerZone2=@zone_id or SellerZone1=@zone_id or SellerZone2=@zone_id))
union all
Select soldURN1,soldURN2,ControlledSubstance,saleQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
Seller_Name,manufacturerName,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,Buyer_Name1,Buyer_Name2,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2 
from UV_ComparativeReportQuarterFormE 
where purchaseURN1=@urn2 and purchaseURN2=@urn1 and ControlledSubstance2=@substance and 
(@zone_id=0 or (BuyerZone1=@zone_id or BuyerZone2=@zone_id or SellerZone1=@zone_id or SellerZone2=@zone_id))
)tmp group by soldURN1,soldURN2,ControlledSubstance,saleQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
Seller_Name,manufacturerName,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,Buyer_Name1,Buyer_Name2,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2
end

if @form='F'
begin
Select soldURN1,soldURN2,ControlledSubstance,soldQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
	Seller_Name1,Seller_Name2,Buyer_Name1,Buyer_Name2,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2 from
	(
	Select soldURN1,soldURN2,ControlledSubstance,soldQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
	Seller_Name1,Seller_Name2,Buyer_Name1,Buyer_Name2,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2 
	from UV_ComparativeReportQuarterFormF 
	where soldURN1=@urn1 and soldURN2=@urn2 and ControlledSubstance=@substance and (@zone_id=0 or (BuyerZone1=@zone_id or BuyerZone2=@zone_id or SellerZone1=@zone_id or SellerZone2=@zone_id))
union all
Select soldURN1,soldURN2,ControlledSubstance,soldQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
	Seller_Name1,Seller_Name2,Buyer_Name1,Buyer_Name2,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2 
	from UV_ComparativeReportQuarterFormF 
	where purchaseURN1=@urn2 and purchaseURN2=@urn1 and ControlledSubstance2=@substance and 
	(@zone_id=0 or (BuyerZone1=@zone_id or BuyerZone2=@zone_id or SellerZone1=@zone_id or SellerZone2=@zone_id))
)tmp group by soldURN1,soldURN2,ControlledSubstance,soldQTY,purchaseURN1,purchaseURN2,PurchaseQTY,ControlledSubstance2,Difference,
	Seller_Name1,Seller_Name2,Buyer_Name1,Buyer_Name2,QTR1,QTR2,BuyerFB_ID,SellerFB_ID,BuyerFB_ID2,SellerFB_ID2,Qtr_ID1,Qtr_ID2
end
GO
/****** Object:  StoredProcedure [dbo].[USP_getReportFormWise]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PRoc [dbo].[USP_getReportFormWise]    

(        

 @Form varchar(50),        

 @LoginId int=0,    

 @ZO_ID int=0,

 @Qtr_ID int=0  

)        

as         

if @Form='ConsumedF'        

begin        

  select fb.FB_ID, ff.URN,ff.Seller_Name, ff.addBy, zm.ZonalOffice,sm.StateName, SUM(ffr.Quantity_Received) as totalConsumed,    

  

  dbo.ufn_ConcatenateSubstances_new(ff.URN, 'Substance', 3,@Qtr_ID)as SubStanceName--, dbo.ufn_ConcatenateSubstances(ff.URN, 'Quantity', 3)as SubStanceQty    

  

  from tn_FormF  ff inner join  tn_FormB fb ON ff.loginID=fb.addBy inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID     

  

  inner join State_Master sm ON ff.State_ID=sm.S_ID left join ff_Receipt_Import ffr on ff.FF_ID = ffr.FF_ID     

  

 -- LEFT JOIN

 -- (

	--SELECT O.newURN,SUM(FR.Quantity_Received)Qty from OldURN O INNER JOIN tn_FormF F ON O.oldURN=F.URN INNER JOIN ff_Receipt_Import FR ON f.FF_ID=FR.FF_ID where FR.Category=3 group by O.newURN

 

 -- )sdf ON ff.URN=sdf.newURN

     

  where ff.deleted=0 and (@LoginId=0 or ff.addBy=@LoginId) and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (Quater=@Qtr_ID or @Qtr_ID=0)  and ffr.Category = 3    

 

 group by ff.URN,ff.Seller_Name, ff.addBy, zm.ZonalOffice,sm.StateName, fb.FB_ID order by ff.URN asc     

     

end     

    

else if @Form='SaleF'        

begin        

  select fb.FB_ID, ff.URN,ff.Seller_Name, ff.addBy, zm.ZonalOffice,sm.StateName, SUM(ffr.Quantity_Received) as totalSale,   

  

  dbo.ufn_ConcatenateSubstances_new(ff.URN, 'Substance', 2,@Qtr_ID)as SubStanceName--, dbo.ufn_ConcatenateSubstances(ff.URN, 'Quantity', 2)as SubStanceQty    

     

 from tn_FormF  ff inner join  tn_FormB fb ON ff.loginID=fb.addBy inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID     

 

 inner join State_Master sm ON ff.State_ID=sm.S_ID left join ff_Receipt_Import ffr on ff.FF_ID = ffr.FF_ID



 --LEFT JOIN

 --(

	--SELECT O.newURN,SUM(FR.Quantity_Received)Qty from OldURN O INNER JOIN tn_FormF F ON O.oldURN=F.URN INNER JOIN ff_Receipt_Import FR ON f.FF_ID=FR.FF_ID where FR.Category=2 group by O.newURN

 

 --)sdf ON ff.URN=sdf.newURN

      

 where ff.deleted=0  and (@LoginId=0 or ff.addBy=@LoginId) and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (Quater=@Qtr_ID or @Qtr_ID=0) and ffr.Category = 2    

 

 group by ff.URN,ff.Seller_Name, ff.addBy, zm.ZonalOffice, fb.FB_ID, sm.StateName order by ff.URN asc     

     

end     

else if @Form='ReceivedF'        

begin        

  select fb.FB_ID, ff.URN,ff.Seller_Name, ff.addBy, zm.ZonalOffice,sm.StateName, SUM(ffr.Quantity_Received) as totalReceipt,    

  

  dbo.ufn_ConcatenateSubstances_new(ff.URN, 'Substance', 1,@Qtr_ID)as SubStanceName--, dbo.ufn_ConcatenateSubstances_new(ff.URN, 'Quantity', 1,@Qtr_ID)as SubStanceQty    

     

 from tn_FormF  ff inner join  tn_FormB fb ON ff.loginID=fb.addBy inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID     

 

 inner join State_Master sm ON ff.State_ID=sm.S_ID INNER join ff_Receipt_Import ffr on ff.FF_ID = ffr.FF_ID     

 

 --LEFT JOIN

 --(

	--SELECT O.newURN,SUM(FR.Quantity_Received)Qty from OldURN O INNER JOIN tn_FormF F ON O.oldURN=F.URN INNER JOIN ff_Receipt_Import FR ON f.FF_ID=FR.FF_ID where FR.Category=1 group by O.newURN

 

 --)sdf ON ff.URN=sdf.newURN

      

 where ff.deleted=0 and (@LoginId=0 or ff.addBy=@LoginId) and (@ZO_ID=0 or fb.ZO_ID=@ZO_ID) and (Quater=@Qtr_ID or @Qtr_ID=0) and ffr.Category = 1    

 

 group by ff.URN,ff.Seller_Name, ff.addBy, zm.ZonalOffice, fb.FB_ID, sm.StateName order by ff.URN asc     

     

end    

    

else if @Form='DestroyedI'        

begin         

 select fb.userRegNo as urn, fb.FB_ID, fb.applicantName, zm.ZonalOffice, sm.StateName,    

 

		dbo.ufn_ConcatenateSubstances(fb.userRegNo, 'DestroyedSubstance', 0)as SubStanceName,    

 

		dbo.ufn_ConcatenateSubstances(fb.userRegNo, 'DestroyedQuantity', 0)as SubStanceQty    

    

 from tn_FormI fi inner join tn_FormB fb on fi.addBy = fb.addBy inner join     

 

		ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID inner join State_Master sm ON fi.stateId = sm.S_ID     

 

 where fi.deleted = 0 

 

 group by fb.userRegNo, fb.applicantName, zm.ZonalOffice, sm.StateName, fb.FB_ID    

     

end    

    

else if @Form='MFD'        

begin      

 select fe.urnNo as urn, fb.FB_ID, fe.manufacturerName, zm.ZonalOffice, sm.StateName,    

 

		dbo.ufn_ConcatenateSubstances(fe.urnNo, 'MFDSubstance', 0)as SubStanceName,    

 

		dbo.ufn_ConcatenateSubstances(fe.urnNo, 'MFDQuantity', 0)as SubStanceQty    

    

 from tn_FormE fe inner join fe_SubStanceDetails feSub on fe.FE_ID = feSub.FE_ID inner join tn_FormB fb on fe.addBy = fb.addBy     

 

		inner join State_Master sm ON fb.S_ID=sm.S_ID  inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID     

 

 where fe.deleted = 0 

 

 group by fe.urnNo, fe.manufacturerName, zm.ZonalOffice, sm.StateName, fb.FB_ID    

end    

    

else if @Form='Sold'        

begin      

 select fe.urnNo as urn, fb.FB_ID, fe.manufacturerName, zm.ZonalOffice, sm.StateName,    

 

		dbo.ufn_ConcatenateSubstances(fe.urnNo, 'SoldSubstance', 0)as SubStanceName,    



		dbo.ufn_ConcatenateSubstances(fe.urnNo, 'SoldQuantity', 0)as SubStanceQty    

    

 from tn_FormE fe inner join fe_SubStanceDetails feSub on fe.FE_ID = feSub.FE_ID inner join tn_FormB fb on fe.addBy = fb.addBy     

 

 inner join State_Master sm ON fb.S_ID=sm.S_ID  inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID     

 

 where fe.deleted = 0

 

 group by fe.urnNo, fe.manufacturerName, zm.ZonalOffice, sm.StateName, fb.FB_ID    

end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetReturnDues_Quarters]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_GetReturnDues_Quarters]

(

	@Id int

)

as

declare @FBID int

declare @currentQtr int

declare @returnfiledQtr int

select @FBID=FB_ID from tn_FormB where deleted=0 and addBy=@Id

declare @result as table(FormName nvarchar(10),QuarterName nvarchar(50))

declare @Activity as table(activity int)



insert into @Activity(activity) select NA_ID from fb_ControlledSubstanceReg where FB_ID=@FBID



select @currentQtr=[dbo].UFN_GetQuarterId(GETDATE())-1



if exists(select activity from @Activity where activity=1)

begin

	if exists(select * from tn_FormE where FB_ID=@FBID and Deleted=0)

	begin

		select @returnfiledQtr=Max(returnQuarter)+1 from tn_FormE where FB_ID=@FBID and Deleted=0

	end

	else

	begin

		select @returnfiledQtr=[dbo].UFN_GetQuarterId(userRegNo_IssueDT) from tn_FormB where FB_ID=@FBID and Deleted=0

	end



	insert into @result(FormName,QuarterName) select 'Form E',Qtr_Name from Quater_Master where Qtr_Id between @returnfiledQtr and @currentQtr

	

end



if exists(select activity from @Activity where activity in (3,4,7,8))

begin

	if exists(select * from tn_FormF where loginID=@Id and Deleted=0)

	begin

		select @returnfiledQtr=Max(Quater)+1 from tn_FormF where loginID=@Id and Deleted=0

	end

	else

	begin

		select @returnfiledQtr=[dbo].UFN_GetQuarterId(userRegNo_IssueDT) from tn_FormB where FB_ID=@FBId and Deleted=0

	end



	insert into @result(FormName,QuarterName) select 'Form F',Qtr_Name from Quater_Master where Qtr_Id between @returnfiledQtr and @currentQtr

	

end



select * from @result
GO
/****** Object:  StoredProcedure [dbo].[USP_GetStateMaster]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_GetStateMaster]
AS
BEGIN
	 select S_ID, StateName from State_Master where Deleted = 0 and Status = 1
END

GO
/****** Object:  StoredProcedure [dbo].[USP_GetSubstance]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GetSubstance]       
(          
@loginId int,          
@action varchar(250),
@SubURN nvarchar(50)='',
@Quarter int=0          
)          
           
AS          
BEGIN          
 if(@action= 'Registered')          
 begin          
  select distinct cs.CS_ID, (select ControlledSubstance from ControlledSubstance_Master where CS_ID = cs.CS_ID)as ControlledSubstance            
  from fb_ControlledSubstanceReg cs where FB_ID in (select FB_ID from tn_FormB where addBy = @loginId)      
           
 end      
   
 else  if(@action= 'RegisteredFormH')          
 begin          
 select distinct CS_ID,(select ControlledSubstance from ControlledSubstance_Master where CS_ID = fb_ControlledSubstanceReg.CS_ID and deleted = 0)as ControlledSubstance       
 from dbo.fb_ControlledSubstanceReg where  FB_ID = (select FB_ID from tn_FormB where addBy = @loginId and status = 1 and deleted = 0)  and NA_ID not in (1, 7)  
 group by CS_ID    
 end    
   
 else if(@action= 'RegisteredFormF')          
 begin    
      
 --select CS_ID, NA_ID, (select NatureActivity from NatureActivity_Master where NA_ID = fb_ControlledSubstanceReg.NA_ID and deleted = 0)as NatureActivity,        
 --(select ControlledSubstance from ControlledSubstance_Master where CS_ID = fb_ControlledSubstanceReg.CS_ID and deleted = 0)as ControlledSubstance         
 --from dbo.fb_ControlledSubstanceReg 
 --where NA_ID = 3 and FB_ID = (select FB_ID from tn_FormB where addBy = @loginId and status = 1 and deleted = 0) and
 --(PremisesAddress=(select PremiseAddress FROM SubURN where subURN=@SubURN)  or @SubURN='')

 select CR.CS_ID, NA.NA_ID,NatureActivity,ControlledSubstance 
 
 from fb_ControlledSubstanceReg CR INNER JOIN tn_FormB FB ON CR.FB_ID=FB.FB_ID INNER JOIN 
 
 ControlledSubstance_Master CM ON CR.CS_ID=CM.CS_ID LEFT OUTER JOIN SubURN SU ON CR.premisesAddress=SU.PremiseAddress INNER JOIN NatureActivity_Master NA ON CR.NA_ID=NA.NA_ID

 WHERE FB.addBy=@loginId and FB.status=1 and FB.deleted=0 and CR.NA_ID=3 and (subURN=@SubURN or @SubURN='') group by CR.CS_ID, NA.NA_ID,NatureActivity,ControlledSubstance 
      
 --select CS_ID, NA_ID, (select NatureActivity from NatureActivity_Master where NA_ID = fb_ControlledSubstanceReg.NA_ID and deleted = 0)as NatureActivity,        
 --(select ControlledSubstance from ControlledSubstance_Master where CS_ID = fb_ControlledSubstanceReg.CS_ID and deleted = 0)as ControlledSubstance         
 --from dbo.fb_ControlledSubstanceReg 
 --where NA_ID = 4 and FB_ID = (select FB_ID from tn_FormB where addBy = @loginId and status = 1 and deleted = 0) and
 --(PremisesAddress=(select PremiseAddress FROM SubURN where subURN=@SubURN)  or @SubURN='')       
 
 select CR.CS_ID, NA.NA_ID,NatureActivity,ControlledSubstance 
 
 from fb_ControlledSubstanceReg CR INNER JOIN tn_FormB FB ON CR.FB_ID=FB.FB_ID INNER JOIN 
 
 ControlledSubstance_Master CM ON CR.CS_ID=CM.CS_ID LEFT OUTER JOIN SubURN SU ON CR.premisesAddress=SU.PremiseAddress INNER JOIN NatureActivity_Master NA ON CR.NA_ID=NA.NA_ID

 WHERE FB.addBy=@loginId and FB.status=1 and FB.deleted=0 and CR.NA_ID=4 and (subURN=@SubURN or @SubURN='') group by CR.CS_ID, NA.NA_ID,NatureActivity,ControlledSubstance
      

 --select CS_ID, NA_ID, (select NatureActivity from NatureActivity_Master where NA_ID = fb_ControlledSubstanceReg.NA_ID and deleted = 0)as NatureActivity,        
 --(select ControlledSubstance from ControlledSubstance_Master where CS_ID = fb_ControlledSubstanceReg.CS_ID and deleted = 0)as ControlledSubstance         
 --from dbo.fb_ControlledSubstanceReg 
 --where NA_ID = 7 and FB_ID = (select FB_ID from tn_FormB where addBy = @loginId and status = 1 and deleted = 0) and
 --(PremisesAddress=(select PremiseAddress FROM SubURN where subURN=@SubURN) or @SubURN='')
 
 select CR.CS_ID, NA.NA_ID,NatureActivity,ControlledSubstance 
 
 from fb_ControlledSubstanceReg CR INNER JOIN tn_FormB FB ON CR.FB_ID=FB.FB_ID INNER JOIN 
 
 ControlledSubstance_Master CM ON CR.CS_ID=CM.CS_ID LEFT OUTER JOIN SubURN SU ON CR.premisesAddress=SU.PremiseAddress INNER JOIN NatureActivity_Master NA ON CR.NA_ID=NA.NA_ID

 WHERE FB.addBy=@loginId and FB.status=1 and FB.deleted=0 and CR.NA_ID=7 and (subURN=@SubURN or @SubURN='') group by CR.CS_ID, NA.NA_ID,NatureActivity,ControlledSubstance   


	DECLARE @tbl as table(ID int identity(1,1),CS1 decimal(18,6),CS2 decimal(18,6),CS3 decimal(18,6),CS4 decimal(18,6),CS5 decimal(18,6),CS6 decimal(18,6),CS7 decimal(18,6),CS8 decimal(18,6),CS9 decimal(18,6))
	INSERT INTO @tbl(CS1,CS2,CS3,CS4,CS5,CS6,CS7,CS8,CS9)VALUES(0,0,0,0,0,0,0,0,0)
	if exists(select * from fb_ControlledSubstanceReg C INNER JOIN tn_FormB B ON C.FB_ID=B.FB_ID where B.addBy=@loginId and NA_ID=1)
	BEGIN
		IF exists(SELECT * from tn_FormE where returnQuarter=@Quarter and addBy=@loginId and deleted=0)
		BEGIN
			delete from @tbl
			INSERT INTO @tbl(CS1,CS2,CS3,CS4,CS5,CS6,CS7,CS8,CS9) select SUM(CASE WHEN CS_ID=1 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=2 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=3 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=4 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=5 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=6 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=7 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=8 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=9 THEN closingBalance else 0 END)
			from tn_FormE E INNER JOIN fe_SubstanceDetails S ON E.FE_ID=S.FE_ID where E.returnQuarter=@Quarter and E.addBy=@loginId and E.deleted=0
		END
		IF not Exists(select * from tn_formF where loginID=@loginId and deleted=0)
		BEGIN
			delete from @tbl
			INSERT INTO @tbl(CS1,CS2,CS3,CS4,CS5,CS6,CS7,CS8,CS9) select TOP 1 SUM(CASE WHEN CS_ID=1 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=2 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=3 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=4 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=5 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=6 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=7 THEN closingBalance else 0 END),SUM(CASE WHEN CS_ID=8 THEN closingBalance else 0 END),
			SUM(CASE WHEN CS_ID=9 THEN closingBalance else 0 END)
			from tn_FormE E INNER JOIN fe_SubstanceDetails S ON E.FE_ID=S.FE_ID where E.returnQuarter=@Quarter and E.addBy=@loginId and E.deleted=0 GROUP BY E.FE_ID ORDER BY E.FE_ID DESC
		END
	END
	ELSE
	if exists(SELECT * from tn_formF where loginID=@loginId and deleted=0)
	BEGIN
		if EXISTS(SELECT * from Quarter_ReturnFiling Q INNER JOIN tn_FormB B ON Q.URN=B.userRegNo where B.deleted=0 and ISNULL(ReturnFiled,0)=0)
		BEGIN
			delete from @tbl
		END
		INSERT INTO @tbl(CS1,CS2,CS3,CS4,CS5,CS6,CS7,CS8,CS9)
		select TOP 1 ISNULL(CS1,0)CS1,ISNULL(CS2,0)CS2,ISNULL(CS3,0)CS3,ISNULL(CS4,0)CS4,ISNULL(CS5,0)CS5,ISNULL(CS6,0)CS6,ISNULL(CS7,0)CS7,
		ISNULL(CS8,0)CS8,ISNULL(CS9,0)CS9
		from tn_formF where loginID=@loginId and deleted=0 order by FF_ID DESC
    END
	
	SELECT ISNULL(SUM(ISNULL(CS1,0)),0)CS1,ISNULL(SUM(ISNULL(CS2,0)),0)CS2,ISNULL(SUM(ISNULL(CS3,0)),0)CS3,ISNULL(SUM(ISNULL(CS4,0)),0)CS4,
	ISNULL(SUM(ISNULL(CS5,0)),0)CS5,ISNULL(SUM(ISNULL(CS6,0)),0)CS6,ISNULL(SUM(ISNULL(CS7,0)),0)CS7,ISNULL(SUM(ISNULL(CS8,0)),0)CS8,
	ISNULL(SUM(ISNULL(CS9,0)),0)CS9 from @tbl
	--ELSE
	--BEGIN
	--    SELECT 0 CS1,0 CS2,0 CS3,0 CS4,0 CS5
	--END
 end       
           
           
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetSubstanceByZone]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_GetSubstanceByZone] --'Acetic Anhydride'
(
	@searchval nvarchar(50)=''
)
AS
BEGIN
	 SELECT CM.ControlledSubstance,ZM.ZonalOffice, COUNT(distinct BM.FB_ID) AS TotalRegistrant 
	 
	 FROM  tn_FormB AS BM INNER JOIN fb_ControlledSubstanceReg AS CB ON BM.FB_ID = CB.FB_ID INNER JOIN 
	 
	 ZonalOffice_Master ZM ON BM.ZO_ID=ZM.ZO_ID INNER JOIN ControlledSubstance_Master CM ON CB.CS_ID=CM.CS_ID
	 
	 WHERE BM.fb_Approval_Status = 'Yes' AND BM.status = 1 AND BM.deleted = 0 and (REPLACE(ControlledSubstance,' ','') like '%'+@searchval+'%' OR ZonalOffice='%'+@searchval+'%' OR @searchval='')
	 
	 GROUP BY CM.ControlledSubstance,ZM.ZonalOffice order by CM.ControlledSubstance,ZM.ZonalOffice
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetSubURN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_GetSubURN] 
(
	@action nvarchar(10)='URN',
	@URN nvarchar(50)=null,
	@Quarter int=0
)
as
BEGIN
	if(@action='URN' or @action='')
	BEGIN
	select id,subURN from SubURN where subURN not in (select subURN from tn_FormF where deleted=0 and Quater=@Quarter and subURN is not null and URN=@URN) and 
	
	status=1 and deleted=0 and parentURN=@URN
	END

	if(@action='detail')
	BEGIN
		SELECT SU.PremiseAddress,CS.S_ID,CS.pinCode,DM.districtName FROM SubURN SU INNER JOIN fb_ControlledSubstanceReg CS ON SU.FB_ID=CS.FB_ID and SU.PremiseAddress=CS.premisesAddress 
		
		LEFT OUTER JOIN District_Master DM ON CS.D_ID=DM.D_ID
		
		WHERE SU.subURN=@URN
	END
	if(@action='Regpop')
	BEGIN
		select SubURN,PremiseAddress,ControlledSubstance,dbo.ufn_GetNatureActivity('Activity', S.FB_ID, F.CS_ID)as NatureActivity 
		
		FROM SubURN S INNER JOIN fb_ControlledSubstanceReg F ON S.premiseAddress=F.premisesAddress INNER JOIN ControlledSubstance_Master C ON F.CS_ID=C.CS_ID where F.deleted=0 and S.deleted=0 and S.parentURN=@URN 
		
		group by SubURN,PremiseAddress,S.FB_ID, F.CS_ID,ControlledSubstance ORDER BY SubURN
	END
END
GO
/****** Object:  StoredProcedure [dbo].[USP_GetUserApplicationStatus]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[USP_GetUserApplicationStatus] 

(        

 @ID int        

)        

as        
		

select (case when userRegNo is not null then 'Unique Registration No. issued :  '+userRegNo        

else case when tempRegNo is not null then --'Temp. Registration No. issued :  '+tempRegNo 

'' else '' end end)RegNo,        

(case when fb_HardCopy_Rcv='Yes' then 'Approved' else case when userRegNo is not null then 'Approval Pending'         

else case when tempRegNo is not null then 'Verification Pending' else 'In-Complete Application' end end end)DocStatus,    

ISNULL(userRegNo,'')userRegNo,FB_ID       

from tn_FormB where addBy=@ID and tempRegNo is not null and status=1 and Deleted=0     

      

select Description from FormB_AddtionalDoc where FB_ID=(select TOP 1 FB_ID from tn_FormB where addBy=@ID and status=1 and Deleted=0)        

      

select (case when stepComplete=1 then 'FormB.2.aspx'      

    when stepComplete=2 then 'FormB.3.aspx'      

    when stepComplete=3 then 'FormB.4.aspx'      

    when stepComplete=4 then 'FormB.5.aspx'      

    when stepComplete>=5 then 'PreviewFormB.aspx' else 'FormBreg.aspx' end)redirecturl,FB_ID      

from tn_formB where addBy=@ID and status=1 and Deleted=0 and tempRegNo is null    

    

    

select distinct 'Form E'as Form,'rcdFormE.aspx'as page from tn_FormE where addBy=@ID and deleted=0   

union    

select distinct 'Form F'as Form,'rcdFormF.aspx'as page from tn_FormF where addBy=@ID and deleted=0    

union    

select distinct 'Form G'as Form,'rcdFormG.aspx'as page from tn_FormG where addBy=@ID  and deleted=0  

union    

select distinct 'Form H'as Form,'rcdFormH.aspx'as page from tn_FormH where addBy=@ID and deleted=0  

union    

select distinct 'Form I'as Form,'rcdFormI.aspx'as page from tn_FormI where addBy=@ID and deleted=0

union    

select distinct 'Form L'as Form,'rcdFormL.aspx'as page from tn_FormL where addBy=@ID and deleted=0

select NA_ID  from tn_FormB fb inner join fb_ControlledSubstanceReg cs ON fb.FB_ID=cs.FB_ID where fb.addBy=@ID and fb.userRegNo is not null and fb.status=1 and fb.deleted=0

declare @qtrId int
declare @qtr int
select @qtrId=Qtr_Id from Quater_Master where case when rtrim(charindex('-',Qtr_Name))-1>0 then left(Qtr_Name,rtrim(charindex('-',Qtr_Name))-2) else 'Q' end='Q'+CAST(datepart(Quarter,GETDATE()) as varchar)+' '+CAST(DATEPART(year,GETDATE()) as varchar)

declare @tbl as table(Form nvarchar(20),Qtr_Name nvarchar(50),Qtr_id int)

--SELECT Form,Qtr_Name FROM(

if exists(SELECT FE_ID from tn_FormE where addBy=@ID and deleted=0)
BEGIN

	if EXISTS(select * from fb_ControlledSubstanceReg where deleted=0 and NA_ID=1)
	BEGIN
	INSERT INTO @tbl(Form,Qtr_Name,Qtr_id) select 'Form E' as Form,Qtr_Name,Qtr_id from Quater_Master where Qtr_id >(select TOP 1 returnQuarter from tn_FormE where addBy=@ID and deleted=0 order by FE_ID DESC) and Qtr_Id < @qtrId 	
	END
END
ELSE
BEGIN
	if exists(SELECT * from tn_FormB B INNER JOIN fb_ControlledSubstanceReg S ON B.FB_ID=S.FB_ID where B.addBy=@ID and S.NA_ID=1 and S.deleted=0 and userRegNo is not null)
	BEGIN
		
		select @qtr=Qtr_ID from Quater_Master where rtrim(LEFT(Qtr_Name,CHARINDEX('-',Qtr_Name)-1))=(select 'Q'+CAST(DATEPART(Quarter,userRegNo_IssueDT) as nvarchar)+' '+CAST(DATEPART(year,userRegNo_IssueDT) as nvarchar) from tn_FormB where addBy=@ID)  and Qtr_Id>0

		INSERT INTO @tbl(Form,Qtr_Name,Qtr_id) SELECT 'Form E',Qtr_Name,Qtr_Id FROM Quater_Master where Qtr_Id<@qtrId and Qtr_ID>@qtr
	END
END

if exists(SELECT FF_ID from tn_FormF where addBy=@ID and deleted=0)
BEGIN
	INSERT INTO @tbl(Form,Qtr_Name,Qtr_id) select 'Form F' as Form,Qtr_Name,Qtr_id from Quater_Master where Qtr_id >(select TOP 1 Quater from tn_FormF where loginId=@ID and deleted=0 order by FF_ID DESC) and Qtr_Id < @qtrId 
END
ELSE
BEGIN
	if exists(SELECT * from tn_FormB B INNER JOIN fb_ControlledSubstanceReg S ON B.FB_ID=S.FB_ID where B.addBy=@ID and S.NA_ID in (2,3,4,5,6,7,8,9) and userRegNo is not null)
	BEGIN
		
		select @qtr=Qtr_ID from Quater_Master where rtrim(LEFT(Qtr_Name,CHARINDEX('-',Qtr_Name)-1))=(select 'Q'+CAST(DATEPART(Quarter,userRegNo_IssueDT) as nvarchar)+' '+CAST(DATEPART(year,userRegNo_IssueDT) as nvarchar) from tn_FormB where addBy=@ID and deleted=0)  and Qtr_Id>0

		INSERT INTO @tbl(Form,Qtr_Name,Qtr_id) SELECT 'Form F',Qtr_Name,Qtr_Id FROM Quater_Master where Qtr_Id<@qtrId and Qtr_ID>@qtr
	END
END

if exists(SELECT FL_ID from tn_FormL where addBy=@ID and deleted=0)
BEGIN
	INSERT INTO @tbl(Form,Qtr_Name,Qtr_id) select 'Form L' as Form,Qtr_Name,Qtr_id from Quater_Master where Qtr_id >(select TOP 1 returnQuarter from tn_FormL where addBy=@ID and deleted=0 order by FL_ID DESC) and Qtr_Id < @qtrId 
END
ELSE
BEGIN
	if exists(SELECT * from tn_FormB B INNER JOIN fb_ControlledSubstanceReg S ON B.FB_ID=S.FB_ID where B.addBy=@ID and S.NA_ID in (11) and userRegNo is not null)
	BEGIN
		
		select @qtr=Qtr_ID from Quater_Master where rtrim(LEFT(Qtr_Name,CHARINDEX('-',Qtr_Name)-1))=(select 'Q'+CAST(DATEPART(Quarter,userRegNo_IssueDT) as nvarchar)+' '+CAST(DATEPART(year,userRegNo_IssueDT) as nvarchar) from tn_FormB where addBy=@ID)  and Qtr_Id>0

		INSERT INTO @tbl(Form,Qtr_Name,Qtr_id) SELECT 'Form F',Qtr_Name,Qtr_Id FROM Quater_Master where Qtr_Id<@qtrId and Qtr_ID>@qtr
	END
END
select Form,Qtr_Name from @tbl
--union    

--select 'Form H' as Form,Qtr_Name,Qtr_id from Quater_Master where Qtr_id >(select TOP 1 Quater from tn_FormH where loginId=@ID and deleted=0 order by FH_ID DESC) and Qtr_Id < @qtrId 
--)ss order by Qtr_id DESC


select parentURN,subURN,premiseAddress from SubURN SB INNER JOIN tn_FormB FB ON SB.FB_ID=FB.FB_ID where SB.status=1 and SB.deleted=0 and FB.deleted=0  and userRegNo is not null and addBy=@ID
--and isnull(FB.IsBlocked,0)=0
GO
/****** Object:  StoredProcedure [dbo].[USP_GetUserApplicationStatus_OPC]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_GetUserApplicationStatus_OPC]    
(      
 @ID int      
)      
as      
      
select (case when userRegNo is not null then 'Unique Registration No. issued :  '+userRegNo       
else case when tempRegNo is not null then 'Temp. Registration No. issued :  '+tempRegNo else '' end end)RegNo,      
(case when fb_HardCopy_Rcv='Yes' then 'Approved' else case when userRegNo is not null then 'Approval Pending'       
else case when tempRegNo is not null then 'Verification Pending' else 'In-Complete Application' end end end)DocStatus,  
userRegNo,FB_ID     
from tn_FormB where addBy=@ID and tempRegNo is not null    
    
select Description from FormB_AddtionalDoc where FB_ID=(select TOP 1 FB_ID from tn_FormB where addBy=@ID and Deleted=0)      
    
select (case when stepComplete=1 then 'FormB.2.aspx'    
    when stepComplete=2 then 'FormB.3.aspx'    
    when stepComplete=3 then 'FormB.4.aspx'    
    when stepComplete=4 then 'FormB.5.aspx'    
    when stepComplete=5 then 'PreviewFormB.aspx' else 'FormBreg.aspx' end)redirecturl,FB_ID    
from tn_formB where addBy=@ID and Deleted=0 and tempRegNo is null  
  
  
select distinct 'Form E'as Form,'rcdFormE.aspx'as page from tn_FormE where addBy=@ID  
union  
select distinct 'Form F'as Form,'rcdFormF.aspx'as page from tn_FormF where addBy=@ID  
union  
select distinct 'Form G'as Form,'rcdFormG.aspx'as page from tn_FormG where addBy=@ID  
union  
select distinct 'Form H'as Form,'rcdFormH.aspx'as page from tn_FormH where addBy=@ID  
union  
select distinct 'Form I'as Form,'rcdFormI.aspx'as page from tn_FormI where addBy=@ID  
  
  
select NA_ID  from tn_FormB fb inner join fb_ControlledSubstanceReg cs ON fb.FB_ID=cs.FB_ID where addBy=@ID and userRegNo is not null
GO
/****** Object:  StoredProcedure [dbo].[USP_History_FormB]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_History_FormB]  
(  
 @FB_ID int  
)  
as  
 select fb.applicantName,(fb.regAnotherZone1+'<br/>'+fb.regAnotherZone2)RegisterZone,fb.earlierSurrendered,LG.applicantAddress,LG.cityName,  
LG.pincode,LG.mobileNo,LG.telephoneNo,LG.faxNo,LG.emailId,LG.panNo,LG.applicantName_Pan,LG.panApplied,LG.panApplyProof,  
LG.businessConstitution,fb.conviction_PendingCases,fb.orderDetails,fb.declarationName,Convert(varchar(30),fb.declareDate,103)declareDate,fb.declarePlace,  
fb.signature,fb.authorizationLetter,fb.authorizationLetterDoc,fb.signingPersonPan,fb.signingPersonPanDoc,fb.applicantPan,  
fb.applicantPanDoc,fb.certificateIncorporation,fb.certificateIncorporationDoc,fb.ownershipProof,fb.ownershipProofDoc,  
fb.drugLicence,fb.drugLicenceDoc,fb.importExportCode,fb.importExportCodeDoc,zo.ZonalOffice,sm.StateName,fb.isSubmitted  
from tn_FormB fb inner join ZonalOffice_Master zo ON fb.ZO_ID=zo.ZO_ID inner join State_Master sm ON fb.S_ID=sm.S_ID inner join CompanyDirector_Proprieter_Log LG ON fb.FB_ID=LG.FB_ID 
where fb.FB_ID=@FB_ID and fb.deleted=0
  
select cs.premisesAddress,(Case cs.PT_ID when 4 then cs.otherPremises else pt.PremisesType end)Premises,  
(Case cs.ON_ID when 5 then cs.otherOccupationNature else oc.PremisesOccupation end)Occupation,  
(cs.commissionate+'<br/>'+cs.division+'<br/>'+cs.range+'<br/>'+cs.address+'<br/>'+cs.contactDetails)Details,  
csm.ControlledSubstance,dbo.ufn_GetActivityByName1(cs.FB_ID,cs.CS_ID,cs.premisesAddress)NatureActivity,  
sm.StateName,dm.districtName,cm.cityName,cs.pinCode  
from fb_ControlledSubstanceReg cs inner join PremisesType_Master pt ON cs.PT_ID=pt.PT_ID inner join  
OccupationNature_Master oc ON cs.ON_ID=oc.ON_ID inner join  
ControlledSubstance_Master csm ON cs.CS_ID=csm.CS_ID inner join State_Master sm ON cs.S_ID=sm.S_ID  
left outer join District_Master dm ON cs.D_ID=dm.D_ID left outer join City_Master cm ON cs.C_ID=cm.C_ID  
where cs.FB_ID=@FB_ID  and cs.deleted=0
group by cs.premisesAddress,(Case cs.PT_ID when 4 then cs.otherPremises else pt.PremisesType end),  
(Case cs.ON_ID when 5 then cs.otherOccupationNature else oc.PremisesOccupation end),  
(cs.commissionate+'<br/>'+cs.division+'<br/>'+cs.range+'<br/>'+cs.address+'<br/>'+cs.contactDetails),  
csm.ControlledSubstance,cs.FB_ID,cs.CS_ID,sm.StateName,dm.districtName,cm.cityName,cs.pinCode  
  
select cs.ControlledSubstance,replace(mi.prodCapacity1,'.00','')prodCapacity1,  
replace(mi.prodCapacity2,'.00','')prodCapacity2,replace(mi.prodCapacity3,'.00','')prodCapacity3,mi.mfdYear1,  
replace(mi.mfdQTY1,'.00','')mfdQTY1,mi.mfdYear2,replace(mi.mfdQTY2,'.00','')mfdQTY2,mi.mfdYear3,  
replace(mi.mfdQTY3,'.00','')mfdQTY3,mi.rawMaterials1,mi.rawMaterials2,mi.rawMaterials3,mf.ManufacturedFor  
  
from fb_ManufactureInfo mi inner join ControlledSubstance_Master cs ON mi.CS_ID=cs.CS_ID inner join ManufacturedFor mf ON mi.MFD_ID=mf.MFD_ID  
where mi.FB_ID=@FB_ID  and mi.deleted=0
  
  
select cs.ControlledSubstance,ci.description,replace(ci.consumptionCapacity1,'.00','')consumptionCapacity1,  
replace(ci.consumptionCapacity2,'.00','')consumptionCapacity2,replace(ci.consumptionCapacity3,'.00','')consumptionCapacity3,ci.consumedYear1,  
replace(ci.consumedQTY1,'.00','')consumedQTY1,ci.consumedYear2,replace(ci.consumedQTY2,'.00','')consumedQTY2,ci.consumedYear3,  
replace(ci.consumedQTY3,'.00','')consumedQTY3,ci.rawMaterials1,ci.rawMaterials2,ci.rawMaterials3  
  
from fb_ConsumptionInfo ci inner join ControlledSubstance_Master cs ON ci.CS_ID=cs.CS_ID  
where ci.FB_ID=@FB_ID  and ci.deleted=0
  
  
select sd.signPersonName,dm.desigName,sd.signPersonAddress,sd.signCity,sd.signPincode,sm.StateName,sd.signMobileNo,  
sd.signTelNo,sd.signFaxNo,sd.signEmailId,sd.signPanNo,sd.signPendingCases,sd.signPendingCasesDetails,  
(case sd.signPhotoID when '' then 'N/A' else sd.signPhotoID end)signPhotoID  
from SigningPerson_Log sd inner join Designation_Master dm ON sd.Desig_ID=dm.Desig_ID inner join State_Master sm ON sd.S_ID=sm.S_ID  
where sd.FB_ID=@FB_ID  and sd.deleted=0
  
  
select departName,businessTransNo,validityUpto from fb_BusinessTransactions where FB_ID=@FB_ID  and deleted=0
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_AdminLogin]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_INS_AdminLogin] 
(
@userID varchar(50), @userPass varchar(50), @UserName varchar(50), @emailID varchar(50), 
@mobileNo varchar(50), @altContanct varchar(50), @ZO_ID int, @accType int, @addBy int,
@loginID int=0
)
AS
BEGIN	
SET NOCOUNT ON;
IF (NOT EXISTS (SELECT loginID FROM NCB_AdminLoginMaster where (userID=@userID) and (@loginID = 0 OR loginID !=@loginID)))
BEGIN
BEGIN TRAN
	IF(@loginID=0)
	BEGIN
		INSERT INTO NCB_AdminLoginMaster
       (userID, userPass, UserName, emailID, mobileNo, altContanct, ZO_ID, accType, addBy, addDate, status, deleted)
		VALUES (@userID, @userPass, @UserName, @emailID, @mobileNo, @altContanct, @ZO_ID, @accType, @addBy, GETDATE(), 0, 0)
	END
    ELSE
	BEGIN
		UPDATE NCB_AdminLoginMaster
		SET userID = @userID, userPass = @userPass, UserName = @UserName, emailID = @emailID, mobileNo = @mobileNo, altContanct = @altContanct, 
        ZO_ID = @ZO_ID, accType = @accType, editBy = @addBy, editDate = GETDATE()
        where loginID=@loginID
    END
	IF @@ERROR <> 0 BEGIN GOTO ErrHld END     
	COMMIT TRAN  
	SELECT 0 Ret_Value
	RETURN (0)
END
ELSE
BEGIN
	SELECT 1 Ret_Value
	RETURN (0)
END
ErrHld:
ROLLBACK TRAN 
RETURN (1)
END
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_AdminLogin1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[USP_INS_AdminLogin1] 
(
@userID varchar(50), @userPass nvarchar(128), @UserName varchar(50), @emailID varchar(50), 
@mobileNo varchar(50), @altContanct varchar(50), @ZO_ID int, @accType int, @addBy int,
@loginID int=0
)
AS
BEGIN	
SET NOCOUNT ON;
IF (NOT EXISTS (SELECT loginID FROM NCB_AdminLoginMaster where (userID=@userID) and (@loginID = 0 OR loginID !=@loginID)))
BEGIN
BEGIN TRAN
	IF(@loginID=0)
	BEGIN
		INSERT INTO NCB_AdminLoginMaster
       (userID, userPass1, UserName, emailID, mobileNo, altContanct, ZO_ID, accType, addBy, addDate, status, deleted)
		VALUES (@userID, @userPass, @UserName, @emailID, @mobileNo, @altContanct, @ZO_ID, @accType, @addBy, GETDATE(), 0, 0)
	END
    ELSE
	BEGIN
		UPDATE NCB_AdminLoginMaster
		SET userID = @userID, userPass1 = @userPass, UserName = @UserName, emailID = @emailID, mobileNo = @mobileNo, altContanct = @altContanct, 
        ZO_ID = @ZO_ID, accType = @accType, editBy = @addBy, editDate = GETDATE()
        where loginID=@loginID
    END
	IF @@ERROR <> 0 BEGIN GOTO ErrHld END     
	COMMIT TRAN  
	SELECT 0 Ret_Value
	RETURN (0)
END
ELSE
BEGIN
	SELECT 1 Ret_Value
	RETURN (0)
END
ErrHld:
ROLLBACK TRAN 
RETURN (1)
END
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_ApplicantAddressDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_ApplicantAddressDetails]    
(    
 @FB_ID int,    
 @applicantAddress varchar(256),    
 @cityName varchar(64),    
 @pincode varchar(8),    
 @S_ID int,    
 @mobileNo varchar(16),    
 @telephoneNo varchar(16),    
 @faxNo varchar(16),    
 @emailId varchar(64),    
 @panNo varchar(16),    
 @applicantName_Pan varchar(128),    
 @panApplied varchar(3),    
 @panApplyProof varchar(128),    
 @businessConstitution varchar(32),
 @Mode varchar(10)    
)    
as    
SET NOCOUNT ON;         
BEGIN TRAN     
begin
declare @stepComplete int
set @stepComplete=3
if @Mode='Update'
begin
	set @stepComplete=5
end    
 UPDATE tn_FormB set    
 applicantAddress=@applicantAddress,    
 cityName=@cityName,    
 pincode=@pincode,    
 S_ID=@S_ID,    
 mobileNo=@mobileNo,    
 telephoneNo=@telephoneNo,    
 faxNo=@faxNo,    
 emailId=@emailId,    
 panNo=@panNo,    
 applicantName_Pan=@applicantName_Pan,    
 panApplied=@panApplied,    
 panApplyProof=@panApplyProof,    
 businessConstitution=@businessConstitution,    
 editDate=getdate(),  
 stepComplete=@stepComplete    
 where FB_ID=@FB_ID    
end    
    
IF @@ERROR <> 0 BEGIN GOTO ErrHld END                 
 COMMIT TRAN              
 SELECT 0 Ret_Value         
 RETURN (0)            
           
        
ErrHld:            
ROLLBACK TRAN             
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_AdditionalDoc]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[USP_INS_fb_AdditionalDoc]
(
	@FB_ID int,
	@description varchar(512),
	@addBy int
)
as
SET NOCOUNT ON;     
BEGIN TRAN 
begin
	insert into FormB_AddtionalDoc(FB_ID,description,addBy)
	values
	(@FB_ID,@description,@addBy)
end

IF @@ERROR <> 0 BEGIN GOTO ErrHld END             
 COMMIT TRAN          
 SELECT 0 Ret_Value     
 RETURN (0)        
       
    
ErrHld:        
ROLLBACK TRAN         
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_ApplicantDeclaration]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_fb_ApplicantDeclaration]  
(  
 @FB_ID int,  
 @conviction_PendingCases varchar(256),  
 @orderDetails varchar(256),  
 @declarationName varchar(128),  
 @declareDate datetime,  
 @declarePlace varchar(64),  
 @signature varchar(128),  
 @authorizationLetter varchar(3),  
 @authorizationLetterDoc varchar(128),  
 @signingPersonPan varchar(3),  
 @signingPersonPanDoc varchar(128),  
 @applicantPan varchar(3),  
 @applicantPanDoc varchar(128),  
 @certificateIncorporation varchar(3),  
 @certificateIncorporationDoc varchar(128),  
 @ownershipProof varchar(3),  
 @ownershipProofDoc varchar(128),  
 @drugLicence varchar(3),  
 @drugLicenceDoc varchar(128),  
 @importExportCode varchar(3),  
 @importExportCodeDoc varchar(128)  
)  
as  
SET NOCOUNT ON;       
BEGIN TRAN   
begin  
 UPDATE tn_FormB set  
 conviction_PendingCases=@conviction_PendingCases,  
 orderDetails=@orderDetails,  
 declarationName=@declarationName,  
 declareDate=@declareDate,  
 declarePlace=@declarePlace,  
 signature=@signature,  
 authorizationLetter=@authorizationLetter,  
 authorizationLetterDoc=@authorizationLetterDoc,  
 signingPersonPan=@signingPersonPan,  
 signingPersonPanDoc=@signingPersonPanDoc,  
 applicantPan=@applicantPan,  
 applicantPanDoc=@applicantPanDoc,  
 certificateIncorporation=@certificateIncorporation,  
 certificateIncorporationDoc=@certificateIncorporationDoc,  
 ownershipProof=@ownershipProof,  
 ownershipProofDoc=@ownershipProofDoc,  
 drugLicence=@drugLicence,  
 drugLicenceDoc=@drugLicenceDoc,  
 importExportCode=@importExportCode,  
 importExportCodeDoc=@importExportCodeDoc,  
 editDate=GETDATE(),
 stepComplete=5  
where FB_ID=@FB_ID  
end  
  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 Ret_Value       
 RETURN (0)          
         
      
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_BusinessTransactions]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_fb_BusinessTransactions]    
(    
 @FB_ID int,    
 @departName varchar(256),    
 @businessTransNo varchar(128),    
 @validityUpto varchar(16),
 @Count int,
 @Mode varchar(10)
)    
as    
SET NOCOUNT ON;         
BEGIN TRAN     
begin
declare @stepComplete int
set @stepComplete=4
if @Mode='Update'
begin
	set @stepComplete=5
end
if exists (select * from fb_BusinessTransactions where FB_ID=@FB_ID and deleted=0 and @Count=0) 
begin
	delete from fb_BusinessTransactions where FB_ID=@FB_ID and deleted=0
end  
insert into fb_BusinessTransactions(FB_ID,departName,businessTransNo,validityUpto)    
values    
   (@FB_ID,@departName,@businessTransNo,@validityUpto)    
 Update tn_FormB set stepComplete=@stepComplete where FB_ID=@FB_ID       
end    
    
IF @@ERROR <> 0 BEGIN GOTO ErrHld END                 
 COMMIT TRAN              
 SELECT 0 Ret_Value         
 RETURN (0)            
           
        
ErrHld:            
ROLLBACK TRAN             
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_ConsumptionInfo]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_fb_ConsumptionInfo]  
(  
 @FB_ID int,  
 @CS_ID int,  
 @description varchar(256),  
 @rawMaterials1 varchar(64),  
 @rawMaterials2 varchar(64),  
 @rawMaterials3 varchar(64),  
 @consumptionCapacity1 decimal(18,2),  
 @consumptionCapacity2 decimal(18,2),  
 @consumptionCapacity3 decimal(18,2),  
 @consumedYear1 varchar(4),  
 @consumedQTY1 decimal(18,2),  
 @consumedYear2 varchar(4),  
 @consumedQTY2 decimal(18,2),  
 @consumedYear3 varchar(4),  
 @consumedQTY3 decimal(18,2),
 @Count int
)  
as  
SET NOCOUNT ON;       
BEGIN TRAN   
begin
declare @stepComplete int
set @stepComplete=2 
if exists(select * from fb_ConsumptionInfo where FB_ID=@FB_ID and @Count=0)
begin
	delete from fb_ConsumptionInfo where FB_ID=@FB_ID
	set @stepComplete=5 
end 
insert into fb_ConsumptionInfo(FB_ID,CS_ID,description,rawMaterials1,rawMaterials2,rawMaterials3,consumptionCapacity1,  
   consumptionCapacity2,consumptionCapacity3,consumedYear1,consumedQTY1,consumedYear2,consumedQTY2,  
   consumedYear3,consumedQTY3)  
values  
   (@FB_ID,@CS_ID,@description,@rawMaterials1,@rawMaterials2,@rawMaterials3,@consumptionCapacity1,  
   @consumptionCapacity2,@consumptionCapacity3,@consumedYear1,@consumedQTY1,@consumedYear2,  
   @consumedQTY2,@consumedYear3,@consumedQTY3)  
  Update tn_FormB set stepComplete=@stepComplete where FB_ID=@FB_ID
end  
  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 Ret_Value       
 RETURN (0)          
         
      
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_ControlledSubstanceReg]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_fb_ControlledSubstanceReg]    
(    
 @FB_ID int,    
 @premisesAddress varchar(256),    
 @PT_ID int,    
 @otherPremises varchar(32),    
 @ON_ID int,    
 @otherOccupationNature varchar(32),    
 @commissionate varchar(64),    
 @division varchar(64),    
 @range varchar(32),    
 @address varchar(256),    
 @contactDetails varchar(32),    
 @CS_ID int,    
 @NA_ID int,  
 @Count int,
 @S_ID int,
 @D_ID int,
 @C_ID int,
 @pinCode varchar(8),
 @OthersNA nvarchar(64)   
)    
as    
SET NOCOUNT ON;         
BEGIN TRAN     
begin    
if exists(select * from fb_ControlledSubstanceReg where FB_ID=@FB_ID and @Count=0)  
begin  
 delete from fb_ControlledSubstanceReg where FB_ID=@FB_ID  
end  
 insert into fb_ControlledSubstanceReg
 (
	FB_ID,premisesAddress,PT_ID,otherPremises,ON_ID,otherOccupationNature,commissionate,
	division,range,address,contactDetails,CS_ID,NA_ID,S_ID,D_ID,C_ID,pinCode,OthersNA
 )    
 values
 (
	@FB_ID,@premisesAddress,@PT_ID,@otherPremises,@ON_ID,@otherOccupationNature,@commissionate,
	@division,@range,@address,@contactDetails,@CS_ID,@NA_ID,@S_ID,@D_ID,@C_ID,@pinCode,@OthersNA
 )    
end    
    
IF @@ERROR <> 0 BEGIN GOTO ErrHld END                 
 COMMIT TRAN              
 SELECT 0 Ret_Value         
 RETURN (0)            
           
        
ErrHld:            
ROLLBACK TRAN             
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_FurnishDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_fb_FurnishDetails]
(
	@FB_ID int,
	@signPersonName varchar(128),
	@Desig_ID int,
	@signPersonAddress varchar(256),
	@signCity varchar(64),
	@signPincode varchar(8),
	@S_ID int,
	@signMobileNo varchar(16),
	@signTelNo varchar(16),
	@signFaxNo varchar(16),
	@signEmailId varchar(64),
	@signPanNo varchar(16),
	@signPendingCases varchar(4),
	@signPendingCasesDetails varchar(512),
	@signPhotoID varchar(256)
)
as
SET NOCOUNT ON;     
BEGIN TRAN 
begin
	insert into fb_FurnishDetails(FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,
	S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID)
	values
	(@FB_ID,@signPersonName,@Desig_ID,@signPersonAddress,@signCity,@signPincode,@S_ID,@signMobileNo,@signTelNo,
	@signFaxNo,@signEmailId,@signPanNo,@signPendingCases,@signPendingCasesDetails,@signPhotoID)
end

IF @@ERROR <> 0 BEGIN GOTO ErrHld END             
 COMMIT TRAN          
 SELECT 0 Ret_Value     
 RETURN (0)        
       
    
ErrHld:        
ROLLBACK TRAN         
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_ManufactureInfo]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_fb_ManufactureInfo]
(
	@FB_ID int,
	@CS_ID int,
	@prodCapacity1 decimal(18,2),
	@prodCapacity2 decimal(18,2),
	@prodCapacity3 decimal(18,2),
	@mfdYear1 varchar(4),
	@mfdQTY1 decimal(18,2),
	@mfdYear2 varchar(4),
	@mfdQTY2 decimal(18,2),
	@mfdYear3 varchar(4),
	@mfdQTY3 decimal(18,2),
	@rawMaterials1 varchar(64),
	@rawMaterials2 varchar(64),
	@rawMaterials3 varchar(64),
	@MFD_ID int,
	@Count int 
)
as
SET NOCOUNT ON;       
BEGIN TRAN   
begin
declare @stepComplete int
set @stepComplete=2 
if exists(select * from fb_ManufactureInfo where FB_ID=@FB_ID and @Count=0)
begin
	delete from fb_ManufactureInfo where FB_ID=@FB_ID
	set @stepComplete=5 
end
insert into fb_ManufactureInfo(FB_ID,CS_ID,prodCapacity1,prodCapacity2,prodCapacity3,mfdYear1,mfdQTY1,mfdYear2,mfdQTY2,
			mfdYear3,mfdQTY3,rawMaterials1,rawMaterials2,rawMaterials3,MFD_ID)
values
			(@FB_ID,@CS_ID,@prodCapacity1,@prodCapacity2,@prodCapacity3,@mfdYear1,@mfdQTY1,@mfdYear2,@mfdQTY2,@mfdYear3,
			 @mfdQTY3,@rawMaterials1,@rawMaterials2,@rawMaterials3,@MFD_ID)
 Update tn_FormB set stepComplete=@stepComplete where FB_ID=@FB_ID
 
 end  
  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 Ret_Value       
 RETURN (0)          
         
      
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fb_SigningPersonDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_fb_SigningPersonDetails]  
(  
 @FB_ID int,  
 @signPersonName varchar(128),  
 @Desig_ID int,  
 @signPersonAddress varchar(256),  
 @signCity varchar(64),  
 @signPincode varchar(8),  
 @S_ID int,  
 @signMobileNo varchar(16),  
 @signTelNo varchar(16),  
 @signFaxNo varchar(16),  
 @signEmailId varchar(64),  
 @signPanNo varchar(16),  
 @signPendingCases varchar(4),  
 @signPendingCasesDetails varchar(512),  
 @signPhotoID varchar(256),
 @Count int  
)  
as  
SET NOCOUNT ON;       
BEGIN TRAN   
begin
if exists(select * from fb_SigningPersonDetails where FB_ID=@FB_ID and @Count=1)
begin
	delete from fb_SigningPersonDetails where FB_ID=@FB_ID
end
 insert into fb_SigningPersonDetails(FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,  
 S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID)  
 values  
 (@FB_ID,@signPersonName,@Desig_ID,@signPersonAddress,@signCity,@signPincode,@S_ID,@signMobileNo,@signTelNo,  
 @signFaxNo,@signEmailId,@signPanNo,@signPendingCases,@signPendingCasesDetails,@signPhotoID)  
end  
  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 Ret_Value       
 RETURN (0)          
         
      
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FE_MFDDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_FE_MFDDetails]
(
	@FED_ID int,
	@mfdDate datetime,
	@mfdQauntity decimal(18,2)
)
as
 insert into fe_ManufactureDetails
 (FED_ID,mfdDate,mfdQauntity)values(@FED_ID,@mfdDate,@mfdQauntity)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FE_SaleDetails]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_FE_SaleDetails]
(
	@FED_ID int,
	@saleDate datetime,
	@urnNo varchar(16),
	@nocNo varchar(16),
	@personName varchar(128),
	@personAddress varchar(256),
	@consignNo varchar(16),
	@consignQTY decimal(18,2)=0
)
as
 insert into fe_SaleDetails
 (FED_ID,saleDate,urnNo,nocNo,personName,personAddress,consignNo,consignQTY)
 values(@FED_ID,@saleDate,@urnNo,@nocNo,@personName,@personAddress,@consignNo,@consignQTY)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_ff_Receipt_Import]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[USP_INS_ff_Receipt_Import]  
(  
@FF_ID int, 
@loginID int, 
@CS_ID int, 
@OP_Balance decimal(18, 2), 
@OP_Date date, 
@URN nvarchar(50), 
@nocNo nvarchar(50), 
@Reciever nvarchar(50), 
@Reciever_Add nvarchar(500), 
@Consignment nvarchar(50), 
@Quantity_Received decimal(18, 2), 
@Total decimal(18, 2), 
@CL_Balance decimal(18, 2), 
@Category int, 
@Add_By int
)  
as  
SET NOCOUNT ON;       
BEGIN TRAN   
begin 
INSERT INTO ff_Receipt_Import
 (FF_ID, loginID, CS_ID, OP_Balance, OP_Date, URN, nocNo, Reciever, Reciever_Add, Consignment, Quantity_Received, Total, CL_Balance, Category, Add_By, 
                      Add_Date)
VALUES (@FF_ID, @loginID, @CS_ID, @OP_Balance, @OP_Date, @URN, @nocNo, @Reciever, @Reciever_Add, @Consignment, @Quantity_Received, @Total, @CL_Balance, @Category, @Add_By, 
                      getdate())
end  

  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 ,@FF_ID as RowIdentity        
 RETURN (0)          
         
      
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_fh_consignments_details]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_INS_fh_consignments_details]
(
@FH_ID int,
@loginID int,
@CS_ID int,
@Sent_Date datetime,
@URN nvarchar(50),
@Quantity decimal(18, 2),
@Name nvarchar(500),
@Sent_Address nvarchar(50),
@ConsignmentNo nvarchar(50),
@Transport_Mode nvarchar(50),
@transportNo nvarchar(50)
)
	
AS
BEGIN
	insert into fh_consignments_details(FH_ID, loginID, CS_ID, Sent_Date, URN, Quantity, Name, Sent_Address, ConsignmentNo, Transport_Mode, 
	transportNo, Add_By, Add_Date, Status, Deleted)
	values(@FH_ID, @loginID, @CS_ID, @Sent_Date, @URN, @Quantity, @Name, @Sent_Address, @ConsignmentNo, @Transport_Mode, @transportNo, @loginID,
	GETDATE(), 1, 0)
	
END

GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FinalSubmissionFormB]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_FinalSubmissionFormB]
(  
 @FB_ID int  
)  
as  
SET NOCOUNT ON;       
BEGIN TRAN   
begin  
 declare @urn varchar(20)  
 declare @returncode varchar(20)  
 exec USP_GET_URN @FB_ID,@returncode OUTPUT  
   
 UPDATE tn_FormB set isSubmitted=1,tempRegNo='Temp_'+@returncode,tempRegNo_Date=GETDATE(),stepComplete=6 where FB_ID=@FB_ID  
end  

if exists(select * from SubURN where parentURN=@returncode and deleted=0)
BEGIN
	UPDATE  SubURN SET deleted=1 where parentURN=@returncode and deleted=0
END

if(select COUNT(distinct(premisesAddress)) from fb_ControlledSubstanceReg where deleted=0 and FB_ID=@FB_ID)>1
BEGIN
	UPDATE SubURN SET deleted=1 where parentURN=@returncode
	declare @tbl as table(id int identity(1,1),premisesAddress nvarchar(256))
	INSERT INTO @tbl(premisesAddress) select distinct(premisesAddress) from fb_ControlledSubstanceReg where deleted=0 and FB_ID=@FB_ID
	declare @count int=1
	if((select COUNT(1) from @tbl)>1)
	BEGIN
	WHILE(select COUNT(1) from @tbl)>=@count
	BEGIN
		declare @PD_ID nvarchar(400)
		--select @PD_ID=COALESCE(''+@PD_ID+''',''','')+convert(varchar,PD_ID) from fb_ControlledSubstanceReg where premisesAddress=(select premisesAddress from @tbl where id=@count)	
		select @PD_ID=COALESCE(@PD_ID+',','')+convert(varchar,PD_ID) from fb_ControlledSubstanceReg where premisesAddress=(select premisesAddress from @tbl where id=@count)	
		declare @returncode1 varchar(20)  
		exec USP_GET_SubURN @FB_ID,@PD_ID,@returncode1 OUTPUT
		INSERT INTO SubURN(parentURN,subURN,FB_ID,PremiseAddress) SELECT @returncode,'SUB'+@returncode1,@FB_ID,premisesAddress from @tbl where id=@count
		set @count=@count+1
	END
	END
	if(@count>1)
	BEGIN
		INSERT Quarter_ReturnFiling(URN,totalSubURN,[quarter]) values(@returncode,@count-1,dbo.UFN_GetCurrentQuarter())
	END
END
  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 Ret_Value       
 RETURN (0)          
         
      
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FormA]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_FormA]
(
@FB_ID int,
@LoginID int

)as
begin
declare @userRe varchar(50)
select @userRe=ltrim(replace(tempRegNo,'Temp_','')) from tn_FormB where FB_ID=@FB_ID
--update tn_FormB set fb_Approval_Status='Yes',fb_Approval_By=@LoginID  where FB_ID=@FB_ID
update tn_FormB set userRegNo=@userRe,userRegNo_IssueDT=GETDATE(),fb_Approval_Status='Yes',fb_Approval_By=@LoginID,
fb_Approval_Date=GETDATE() where FB_ID=@FB_ID

end
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FormBpart1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_FormBpart1]    
(    
 @applicantName varchar(128),    
 @ZO_ID int,    
 @regAnotherZone1 varchar(128),    
 @regAnotherZone2 varchar(128),    
 @earlierSurrendered varchar(128),    
 @ID int=0,    
 @addBy int    
)    
as    
SET NOCOUNT ON;         
BEGIN TRAN     
declare @return varchar(20)       
if @ID=0    
begin    
 insert into tn_FormB(applicantName,ZO_ID,regAnotherZone1,regAnotherZone2,earlierSurrendered,addBy,stepComplete)    
 values(UPPER(@applicantName),@ZO_ID,@regAnotherZone1,@regAnotherZone2,@earlierSurrendered,@addBy,1)    
     
 select @return=SCOPE_IDENTITY()    
end    
else    
begin    
 UPDATE tn_FormB set    
 applicantName=@applicantName,    
 ZO_ID=@ZO_ID,    
 regAnotherZone1=@regAnotherZone1,    
 regAnotherZone2=@regAnotherZone2,    
 earlierSurrendered=@earlierSurrendered,    
 editBy=@addBy OUTPUT inserted.FB_ID as  RowIdentity, 0 as Ret_Value 
 where FB_ID=@ID    
end    
    
IF @@ERROR <> 0 BEGIN GOTO ErrHld END                 
 COMMIT TRAN              
 SELECT 0 Ret_Value,@return as RowIdentity          
 RETURN (0)            
           
        
ErrHld:            
ROLLBACK TRAN             
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FormE]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_INS_FormE]  
(  
 @FB_ID int,  
 @returnQuarter int,  
 @urnNo varchar(16),  
 @manufacturerName varchar(128),  
 @address varchar(256),  
 @S_ID int,  
 @city varchar(64),  
 @pincode varchar(8),  
 @returnFilled varchar(8),  
 @reasonDelaySubmission varchar(256),  
 @name varchar(64),  
 @designation varchar(128),  
 @declarationDate datetime,  
 @addBy int  
)  
as  
SET NOCOUNT ON;           
BEGIN TRAN    
declare @return varchar(20)
if not exists(select * from tn_FormE where returnQuarter=@returnQuarter and urnNo=@urnNo)
begin   
insert into tn_FormE  
(FB_ID,returnQuarter,urnNo,manufacturerName,address,S_ID,city,pincode,returnFilled,reasonDelaySubmission,  
name,designation,declarationDate,addBy)  
values  
(@FB_ID,@returnQuarter,@urnNo,@manufacturerName,@address,@S_ID,@city,@pincode,@returnFilled,@reasonDelaySubmission,  
@name,@designation,@declarationDate,@addBy)  
end  
select @return=SCOPE_IDENTITY()    
IF @@ERROR <> 0 BEGIN GOTO ErrHld END                   
 COMMIT TRAN                
 SELECT 0 Ret_Value,@return as RowIdentity            
 RETURN (0)              
             
          
ErrHld:              
ROLLBACK TRAN               
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FormESubStances]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_FormESubStances]
(
	@FE_ID int,
	@CS_ID int,
	@openingBalance decimal(18,2)=0,
	@closingBalance decimal(18,2)=0,
	@totalManufacture decimal(18,2)=0,
	@totalSale decimal(18,2)=0
)
as
SET NOCOUNT ON;         
BEGIN TRAN  
declare @return varchar(20) 
insert into fe_SubStanceDetails
(FE_ID,CS_ID,openingBalance,closingBalance,totalManufacture,totalSale)
values
(@FE_ID,@CS_ID,@openingBalance,@closingBalance,@totalManufacture,@totalSale)

select @return=SCOPE_IDENTITY()  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END                 
 COMMIT TRAN              
 SELECT 0 Ret_Value,@return as RowIdentity          
 RETURN (0)            
           
        
ErrHld:            
ROLLBACK TRAN             
RETURN (1)



GO
/****** Object:  StoredProcedure [dbo].[USP_INS_FormL]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_INS_FormL]
(
	@returnQuarter int,
	@urn nvarchar(16),
	@brokerName nvarchar(128),
	@brokerAddress nvarchar(128),
	@portalDetails nvarchar(256),
	@nofEnquiries int,
	@returnFilledPerson nvarchar(128),
	@designation nvarchar(32),
	@returnSubmitDate datetime,
	@seller FL_Return READONLY,
	@buyer FL_Return READONLY,
	@addBy int
)
AS
SET NOCOUNT ON;       

BEGIN TRAN   
DECLARE @Id int

BEGIN
	INSERT INTO tn_FormL(returnQuarter,urn,brokerName,brokerAddress,portalDetails,nofEnquiries,returnFilledPerson,
				designation,returnSubmitDate,addBy)
	VALUES
	(@returnQuarter,@urn,@brokerName,@brokerAddress,@portalDetails,@nofEnquiries,@returnFilledPerson,@designation,
			@returnSubmitDate,@addBy)

	
	SELECT @Id=SCOPE_IDENTITY()

	INSERT INTO fl_BuyerSeller(FL_ID,loginId,recordType,enqDate,CS_ID,qty,rate,name,address,telephoneNo,emailId,
				URN,ipAddress,paymentDetails,drugLicense,regObtained)
	SELECT @Id,@addBy,1,enqDate,CS_ID,qty,rate,name,address,telephoneNo,emailId,URN,ipAddress,paymentDetails,
				drugLicense,regObtained from @seller

	INSERT INTO fl_BuyerSeller(FL_ID,loginId,recordType,enqDate,CS_ID,qty,rate,name,address,telephoneNo,emailId,
				URN,ipAddress,paymentDetails,drugLicense,regObtained)
	SELECT @Id,@addBy,2,enqDate,CS_ID,qty,rate,name,address,telephoneNo,emailId,URN,ipAddress,paymentDetails,
				drugLicense,regObtained from @buyer
END
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 Ret_Value,@Id as Retval        
 RETURN (0)          
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_Signup]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_Signup]
(
	@userID varchar(64),
	@userPass varchar(32),
	@applicantName varchar(128),
	@applyingName varchar(128),
	@emailID varchar(64),
	@mobileNo varchar(16),
	@altContanct varchar(16),
	@addBy int,
	@ID int=0
)
as
SET NOCOUNT ON;     
BEGIN TRAN  
declare @return varchar(2)
declare @currid int 
if @ID=0
begin
if not exists (select userID from NCB_LoginMaster where userID= @userID and accType='user')
begin
	insert into NCB_LoginMaster(userID,userPass,applicantName,applyingName,emailID,mobileNo,altContanct,addBy)
	values
	(@userID,@userPass,UPPER(@applicantName),@applyingName,@emailID,@mobileNo,@altContanct,@addBy)
	set @return='0'
	
	select @ID=isnull(MAX(loginID),0) from NCB_LoginMaster where deleted=0
end

else
begin
	set @return='1'
end

end
else
begin
	update NCB_LoginMaster set
	userID=@userID,
	userPass=@userPass,
	applicantName=upper(@applicantName),
	applyingName=@applyingName,
	emailID=@emailID,
	mobileNo=@mobileNo,
	altContanct=@altContanct,
	editBy=@addBy,
	editDate=GETDATE()
end
IF @@ERROR <> 0 BEGIN GOTO ErrHld END             
 COMMIT TRAN          
 SELECT 0 Ret_Value,@return as RetType,@ID as CurrId
 RETURN (0)        
       
    
ErrHld:        
ROLLBACK TRAN         
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_Signup1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_INS_Signup1]
(
	@userID varchar(64),
	@userPass nvarchar(128),
	@applicantName varchar(128),
	@applyingName varchar(128),
	@emailID varchar(64),
	@mobileNo varchar(16),
	@altContanct varchar(16),
	@addBy int,
	@ID int=0
)
as
SET NOCOUNT ON;     
BEGIN TRAN  
declare @return varchar(2)
declare @currid int 
declare @verID nvarchar(128)

if @ID=0
begin
if not exists (select userID from NCB_LoginMaster where userID= @userID and accType='user')
begin
	select @verID=NEWID()
	insert into NCB_LoginMaster(userID,userPass1,applicantName,applyingName,emailID,mobileNo,altContanct,addBy,verficationID)
	values
	(@userID,@userPass,upper(@applicantName),@applyingName,@emailID,@mobileNo,@altContanct,@addBy,@verID)
	set @return='0'
	
	select @ID=isnull(MAX(loginID),0) from NCB_LoginMaster where deleted=0
end

else
begin
	set @return='1'
end

end
else
begin
	update NCB_LoginMaster set
	userID=@userID,
	userPass1=@userPass,
	applicantName=upper(@applicantName),
	applyingName=@applyingName,
	emailID=@emailID,
	mobileNo=@mobileNo,
	altContanct=@altContanct,
	editBy=@addBy,
	editDate=GETDATE()
end
IF @@ERROR <> 0 BEGIN GOTO ErrHld END             
 COMMIT TRAN          
 SELECT 0 Ret_Value,@return as RetType,@ID as CurrId,@verID as verID
 RETURN (0)        
       
    
ErrHld:        
ROLLBACK TRAN         
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_SubCategoty_NatureActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_INS_SubCategoty_NatureActivity]
(
	@FB_ID int,
	@SubNatureActivity SubNatureActivity READONLY,
	@SubSubNatureActivity SubSubNatureActivity READONLY
)
AS
BEGIN
	if exists(SELECT * from fb_ControlledSubstance_SubNatureActivity where FB_ID=@FB_ID and Deleted=0)
	BEGIN
		UPDATE fb_ControlledSubstance_SubNatureActivity SET Deleted=1 where FB_ID=@FB_ID
	END
	INSERT INTO fb_ControlledSubstance_SubNatureActivity(FB_ID,premisesAddress,CS_ID,S_NA_ID,Others)
	SELECT @FB_ID,premisesAddress,CS_ID,S_NA_ID,Others FROM @SubNatureActivity
	
	if exists(SELECT * from fb_ControlledSubstance_SubSubNatureActivity where FB_ID=@FB_ID and Deleted=0)
	BEGIN
		UPDATE fb_ControlledSubstance_SubSubNatureActivity SET Deleted=1 where FB_ID=@FB_ID
	END

	INSERT INTO fb_ControlledSubstance_SubSubNatureActivity(FB_ID,premisesAddress,CS_ID,SS_NA_ID)
	SELECT @FB_ID,premisesAddress,CS_ID,SS_NA_ID FROM @SubSubNatureActivity
END
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_tn_FormG]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_INS_tn_FormG]  
(  
@serialNo varchar(50),  
@createDate datetime,  
@regNoConsignor varchar(20),  
@nameConsignor varchar(250),  
@addressConsignor varchar(500),  
@cityConsignor varchar(500),  
@stateIdConsignor int,  
@pincodeConsignor varchar(10),  
@nameConsignerMan varchar(250),  
@nameConsignee varchar(250),  
@transportMode varchar(250),  
@addBy int  
)  
   
AS  
BEGIN  
  
 insert into tn_FormG(serialNo, createDate, regNoConsignor, nameConsignor, addressConsignor, cityConsignor, stateIdConsignor, pincodeConsignor,   
 nameConsignerMan, nameConsignee, transportMode, addBy, deleted)  
   
 values(@serialNo, @createDate, @regNoConsignor, @nameConsignor, @addressConsignor, @cityConsignor, @stateIdConsignor, @pincodeConsignor,   
 @nameConsignerMan, @nameConsignee, @transportMode, @addBy, 0)  
   
 select IDENT_CURRENT('tn_FormG')as FG_Id  
   
END  
  
GO
/****** Object:  StoredProcedure [dbo].[USP_INS_tn_FormH]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_INS_tn_FormH]
(
@loginID int,
@Quater int,
@URN nvarchar(50),
@consignor_Name nvarchar(50),
@Address nvarchar(200),
@Signature nvarchar(50),
@Name nvarchar(50),
@Designation nvarchar(50),
@Sign_DT datetime
)
	
AS
BEGIN
	insert into tn_FormH(loginID, Quater, URN, consignor_Name, Address, Signature, Name, Designation, Sign_DT, addBy, addDate, status, deleted)
	
	values(@loginID, @Quater, @URN, @consignor_Name, @Address, @Signature, @Name, @Designation, @Sign_DT, @loginID, GETDATE(), 1, 0)
	
	select IDENT_CURRENT('tn_FormH')as FH_ID
	
END

GO
/****** Object:  StoredProcedure [dbo].[USP_INS_tn_FormI]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_INS_tn_FormI]
(
@applicantName varchar(250),
@address varchar(250),
@city varchar(250),
@stateId int,
@pincode varchar(10),
@date datetime,
@place varchar(250),
@signature varchar(250),
@name varchar(250),
@designation varchar(250),
@addBy int
)
	
AS
BEGIN

	insert into tn_FormI(applicantName, address, city, stateId, pincode, date, place, signature, name, designation, addBy,addDate,status, deleted)
	values(@applicantName, @address, @city, @stateId, @pincode, @date, @place, @signature, @name, @designation, @addBy,GETDATE(),0, 0)
	
	select IDENT_CURRENT('tn_FormI')as FI_Id
	
END

GO
/****** Object:  StoredProcedure [dbo].[USP_INS_tn_FormI_SubstanceCotrolled]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_INS_tn_FormI_SubstanceCotrolled]
(
@FI_Id int,
@CS_Id int,
@destroyedQty decimal(18, 2),
@typeOfPackage varchar(250),
@storagePlace varchar(250),
@reasons varchar(250),
@manner varchar(250),
@appearQty varchar(50),
@returnFiledQty varchar(50),
@addBy int
)
	
AS
BEGIN

	insert into tn_FormI_SubstanceCotrolled(FI_Id, CS_Id, destroyedQty, typeOfPackage, storagePlace, reasons, manner, appearQty, returnFiledQty, addBy, deleted)
	values(@FI_Id, @CS_Id, @destroyedQty, @typeOfPackage, @storagePlace, @reasons, @manner, @appearQty, @returnFiledQty, @addBy, 0)
	
	
END

GO
/****** Object:  StoredProcedure [dbo].[USP_INS_tnFormG_ConsignmentDesc]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_INS_tnFormG_ConsignmentDesc]
(
@FG_Id int,
@CS_Id int,
@sentDate datetime,
@URN varchar(50),
@name varchar(250),
@address varchar(250),
@noOfPackage decimal(18, 2),
@quantity decimal(18, 2)
)
	
AS
BEGIN

	insert into tnFormG_ConsignmentDesc(FG_Id, CS_Id, sentDate, URN, name, address, noOfPackage, quantity)
	values(@FG_Id, @CS_Id, @sentDate, @URN, @name, @address, @noOfPackage, @quantity)
	
END

GO
/****** Object:  StoredProcedure [dbo].[USP_LogPrprieterDirectorInfo]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_LogPrprieterDirectorInfo]    
(    
 @FB_ID int,   
 @applicantName varchar(128), 
 @applicantAddress varchar(256),    
 @cityName varchar(64),    
 @pincode varchar(8),    
 @S_ID int,    
 @mobileNo varchar(16),    
 @telephoneNo varchar(16),    
 @faxNo varchar(16),    
 @emailId varchar(64),    
 @panNo varchar(16),    
 @applicantName_Pan varchar(128),    
 @panApplied varchar(3),    
 @panApplyProof varchar(128),    
 @businessConstitution varchar(32),
 @ControlledSubstance ControlledSubstanceReg_Log READONLY,
 @SigningPerson SigningPerson READONLY,
 @BusinessTransaction BusinessTransactionNo READONLY,
 @SubActivity SubNatureActivity READONLY,
 @SubSubActivity SubSubNatureActivity READONLY,
 @loginId int=0    
)    

as    

SET NOCOUNT ON;         

BEGIN TRAN 

 INSERT INTO CompanyDirector_Proprieter_Log(FB_ID,applicantName,applicantAddress,cityName,pincode,S_ID,mobileNo,telephoneNo,faxNo,emailId,panNo,applicantName_Pan,panApplied,panApplyProof,businessConstitution,addBy,addDate,status,deleted) 

 SELECT FB_ID,applicantName, applicantAddress, cityName,pincode,S_ID,mobileNo,telephoneNo,faxNo,emailId,panNo,applicantName_Pan,panApplied,panApplyProof,businessConstitution,@loginId,GETDATE(),1,0 from tn_FormB where FB_ID=@FB_ID
 
 DECLARE @Id int

 select @Id=SCOPE_IDENTITY()

 INSERT INTO SigningPerson_Log(L_ID,FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID)

 select @Id, FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID from fb_SigningPersonDetails where FB_ID=@FB_ID
   
 INSERT INTO ControlledSubstanceReg_Log(FB_ID,L_ID,premisesAddress,PT_ID,otherPremises,ON_ID,otherOccupationNature,commissionate,division,range,address,contactDetails,
										
			 CS_ID,NA_ID,status,deleted,S_ID,D_ID,C_ID,pinCode,OthersNA)

select FB_ID,@Id,  premisesAddress, PT_ID, otherPremises, ON_ID, otherOccupationNature, commissionate, division, range, address, contactDetails,
			
			CS_ID,NA_ID,status,deleted,S_ID,D_ID,C_ID,pinCode,OthersNA FROM fb_ControlledSubstanceReg where FB_ID=@FB_ID

insert into fb_BusinessTransactions_Log(FB_ID,departName,businessTransNo,validityUpto,Status,Deleted)
SELECT FB_ID,departName,businessTransNo,validityUpto,Status,Deleted from fb_BusinessTransactions where FB_ID=@FB_ID

 UPDATE tn_FormB set    
	 applicantName = @applicantName,

	 applicantAddress=@applicantAddress,cityName=@cityName, pincode=@pincode, S_ID=@S_ID,    

	 mobileNo=@mobileNo, telephoneNo=@telephoneNo, faxNo=@faxNo, emailId=@emailId,    

	 panNo=@panNo, applicantName_Pan=@applicantName_Pan, panApplied=@panApplied,    

	 panApplyProof=@panApplyProof, businessConstitution=@businessConstitution,    

	 editDate=getdate()  where FB_ID=@FB_ID    

 UPDATE fb_ControlledSubstanceReg SET deleted=1 where FB_ID=@FB_ID and deleted=0

 UPDATE fb_SigningPersonDetails SET deleted=1 where FB_ID=@FB_ID and deleted=0

 UPDATE fb_BusinessTransactions SET deleted=1 where FB_ID=@FB_ID and deleted=0

 INSERT INTO fb_ControlledSubstanceReg(FB_ID,premisesAddress,PT_ID,otherPremises,ON_ID,otherOccupationNature,commissionate,division,
 
			range,address,contactDetails,CS_ID,NA_ID,S_ID,D_ID,C_ID,pinCode,OthersNA)

SELECT @FB_ID,premisesAddress,PT_ID,otherPremises,ON_ID,otherOccupationNature,commissionate,division,range,address,contactDetails,CS_ID,NA_ID,

			S_ID,D_ID,C_ID,pinCode,OthersNA FROM @ControlledSubstance

 INSERT INTO fb_SigningPersonDetails(FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID)

 select  FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID from @SigningPerson

 INSERT INTO fb_BusinessTransactions(FB_ID,departName,businessTransNo,validityUpto)

 SELECT @FB_ID,departName,businessTransNo,validityUpto from @BusinessTransaction
 
	if exists(SELECT * from fb_ControlledSubstance_SubNatureActivity where FB_ID=@FB_ID and Deleted=0)
	BEGIN
		UPDATE fb_ControlledSubstance_SubNatureActivity SET Deleted=1 where FB_ID=@FB_ID
	END
	INSERT INTO fb_ControlledSubstance_SubNatureActivity(FB_ID,premisesAddress,CS_ID,S_NA_ID,Others)
	SELECT @FB_ID,premisesAddress,CS_ID,S_NA_ID,Others FROM @SubActivity
	
	if exists(SELECT * from fb_ControlledSubstance_SubSubNatureActivity where FB_ID=@FB_ID and Deleted=0)
	BEGIN
		UPDATE fb_ControlledSubstance_SubSubNatureActivity SET Deleted=1 where FB_ID=@FB_ID
	END

	INSERT INTO fb_ControlledSubstance_SubSubNatureActivity(FB_ID,premisesAddress,CS_ID,SS_NA_ID)
	SELECT @FB_ID,premisesAddress,CS_ID,SS_NA_ID FROM @SubSubActivity

	if(select COUNT(distinct(premisesAddress)) from @ControlledSubstance)>1
	BEGIN
		DECLARE @returncode nvarchar(20)
		SELECT @returncode=userRegNo From tn_FormB where FB_ID=@FB_ID

		declare @tbl as table(id int identity(1,1),premisesAddress nvarchar(256))
		INSERT INTO @tbl(premisesAddress) select distinct(premisesAddress) from @ControlledSubstance
		declare @count int=1
		if((select COUNT(1) from @tbl)>1)
		BEGIN
			WHILE(select COUNT(1) from @tbl)>=@count
			BEGIN
				declare @PD_ID nvarchar(400)
				declare @premiseaddress nvarchar(256)
				SELECT @premiseaddress=premisesAddress from @tbl where id=@count
				if not exists(select * from SubURN where rtrim(ltrim(PremiseAddress))=rtrim(ltrim(@premiseaddress)) and deleted=0)
				BEGIN
					--select @PD_ID=COALESCE(''+@PD_ID+''',''','')+convert(varchar,PD_ID) from fb_ControlledSubstanceReg where premisesAddress=(select premisesAddress from @tbl where id=@count)	
					select @PD_ID=COALESCE(@PD_ID+',','')+convert(varchar,PD_ID) from fb_ControlledSubstanceReg where premisesAddress=(@premiseaddress) and deleted=0 and FB_ID=@FB_ID	
					declare @returncode1 varchar(20)  
					exec USP_GET_SubURN @FB_ID,@PD_ID,@returncode1 OUTPUT
					INSERT INTO SubURN(parentURN,subURN,FB_ID,PremiseAddress) SELECT @returncode,'SUB'+@returncode1,@FB_ID,premisesAddress from @tbl where id=@count
				END
				
				set @count=@count+1
			END
		END
		if(@count>1)
		BEGIN
			if not exists(SELECT * from Quarter_ReturnFiling where URN=@returncode)
			BEGIN
				INSERT Quarter_ReturnFiling(URN,totalSubURN,[quarter]) values(@returncode,@count-1,dbo.UFN_GetCurrentQuarter())
			END
			else
			BEGIN
				if(select totalSubURN from Quarter_ReturnFiling where URN=@returncode)<>@count-1
				BEGIN
					UPDATE Quarter_ReturnFiling SET totalSubURN=@count-1 where URN=@returncode
				END
			END
		END
		UPDATE SubURN SET deleted=1 where PremiseAddress not in (select premisesAddress from @ControlledSubstance) and parentURN=@returncode
	END
	ELSE
	BEGIN
		if exists(SELECT * from SubURN where parentURN=@returncode and deleted=0)
		BEGIN
			UPDATE SubURN SET deleted=1 where parentURN=@returncode and deleted=0
			DELETE from Quarter_ReturnFiling where URN=@returncode
		END
	END

IF @@ERROR <> 0 BEGIN GOTO ErrHld END                 

 COMMIT TRAN              

 SELECT 0 Ret_Value  

ErrHld:            

ROLLBACK TRAN             

RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_LogPrprieterDirectorInfo_Old]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_LogPrprieterDirectorInfo_Old]    
(    
 @FB_ID int,   
 @applicantName varchar(128), 
 @applicantAddress varchar(256),    
 @cityName varchar(64),    
 @pincode varchar(8),    
 @S_ID int,    
 @mobileNo varchar(16),    
 @telephoneNo varchar(16),    
 @faxNo varchar(16),    
 @emailId varchar(64),    
 @panNo varchar(16),    
 @applicantName_Pan varchar(128),    
 @panApplied varchar(3),    
 @panApplyProof varchar(128),    
 @businessConstitution varchar(32),
 @ControlledSubstance ControlledSubstanceReg_Log READONLY,
 @SigningPerson SigningPerson READONLY,
 @BusinessTransaction BusinessTransactionNo READONLY,
 @SubActivity SubNatureActivity READONLY,
 @SubSubActivity SubSubNatureActivity READONLY,
 @loginId int=0    
)    

as    

SET NOCOUNT ON;         

BEGIN TRAN 

 INSERT INTO CompanyDirector_Proprieter_Log(FB_ID,applicantName,applicantAddress,cityName,pincode,S_ID,mobileNo,telephoneNo,faxNo,emailId,panNo,applicantName_Pan,panApplied,panApplyProof,businessConstitution,addBy,addDate,status,deleted) 

 SELECT FB_ID,applicantName, applicantAddress, cityName,pincode,S_ID,mobileNo,telephoneNo,faxNo,emailId,panNo,applicantName_Pan,panApplied,panApplyProof,businessConstitution,@loginId,GETDATE(),1,0 from tn_FormB where FB_ID=@FB_ID
 
 DECLARE @Id int

 select @Id=SCOPE_IDENTITY()

 INSERT INTO SigningPerson_Log(L_ID,FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID)

 select @Id, FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID from fb_SigningPersonDetails where FB_ID=@FB_ID
   
 INSERT INTO ControlledSubstanceReg_Log(FB_ID,L_ID,premisesAddress,PT_ID,otherPremises,ON_ID,otherOccupationNature,commissionate,division,range,address,contactDetails,
										
			 CS_ID,NA_ID,status,deleted,S_ID,D_ID,C_ID,pinCode,OthersNA)

select FB_ID,@Id,  premisesAddress, PT_ID, otherPremises, ON_ID, otherOccupationNature, commissionate, division, range, address, contactDetails,
			
			CS_ID,NA_ID,status,deleted,S_ID,D_ID,C_ID,pinCode,OthersNA FROM fb_ControlledSubstanceReg where FB_ID=@FB_ID

insert into fb_BusinessTransactions_Log(FB_ID,departName,businessTransNo,validityUpto,Status,Deleted)
SELECT FB_ID,departName,businessTransNo,validityUpto,Status,Deleted from fb_BusinessTransactions where FB_ID=@FB_ID

 UPDATE tn_FormB set    
	 applicantName = @applicantName,

	 applicantAddress=@applicantAddress,cityName=@cityName, pincode=@pincode, S_ID=@S_ID,    

	 mobileNo=@mobileNo, telephoneNo=@telephoneNo, faxNo=@faxNo, emailId=@emailId,    

	 panNo=@panNo, applicantName_Pan=@applicantName_Pan, panApplied=@panApplied,    

	 panApplyProof=@panApplyProof, businessConstitution=@businessConstitution,    

	 editDate=getdate()  where FB_ID=@FB_ID    

 UPDATE fb_ControlledSubstanceReg SET deleted=1 where FB_ID=@FB_ID and deleted=0

 UPDATE fb_SigningPersonDetails SET deleted=1 where FB_ID=@FB_ID and deleted=0

 UPDATE fb_BusinessTransactions SET deleted=1 where FB_ID=@FB_ID and deleted=0

 INSERT INTO fb_ControlledSubstanceReg(FB_ID,premisesAddress,PT_ID,otherPremises,ON_ID,otherOccupationNature,commissionate,division,
 
			range,address,contactDetails,CS_ID,NA_ID,S_ID,D_ID,C_ID,pinCode,OthersNA)

SELECT @FB_ID,premisesAddress,PT_ID,otherPremises,ON_ID,otherOccupationNature,commissionate,division,range,address,contactDetails,CS_ID,NA_ID,

			S_ID,D_ID,C_ID,pinCode,OthersNA FROM @ControlledSubstance

 INSERT INTO fb_SigningPersonDetails(FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID)

 select  FB_ID,signPersonName,Desig_ID,signPersonAddress,signCity,signPincode,S_ID,signMobileNo,signTelNo,signFaxNo,signEmailId,signPanNo,signPendingCases,signPendingCasesDetails,signPhotoID from @SigningPerson

 INSERT INTO fb_BusinessTransactions(FB_ID,departName,businessTransNo,validityUpto)

 SELECT @FB_ID,departName,businessTransNo,validityUpto from @BusinessTransaction
 
	if exists(SELECT * from fb_ControlledSubstance_SubNatureActivity where FB_ID=@FB_ID and Deleted=0)
	BEGIN
		UPDATE fb_ControlledSubstance_SubNatureActivity SET Deleted=1 where FB_ID=@FB_ID
	END
	INSERT INTO fb_ControlledSubstance_SubNatureActivity(FB_ID,premisesAddress,CS_ID,S_NA_ID,Others)
	SELECT @FB_ID,premisesAddress,CS_ID,S_NA_ID,Others FROM @SubActivity
	
	if exists(SELECT * from fb_ControlledSubstance_SubSubNatureActivity where FB_ID=@FB_ID and Deleted=0)
	BEGIN
		UPDATE fb_ControlledSubstance_SubSubNatureActivity SET Deleted=1 where FB_ID=@FB_ID
	END

	INSERT INTO fb_ControlledSubstance_SubSubNatureActivity(FB_ID,premisesAddress,CS_ID,SS_NA_ID)
	SELECT @FB_ID,premisesAddress,CS_ID,SS_NA_ID FROM @SubSubActivity

IF @@ERROR <> 0 BEGIN GOTO ErrHld END                 

 COMMIT TRAN              

 SELECT 0 Ret_Value         

 RETURN (0)            
        

ErrHld:            

ROLLBACK TRAN             

RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_ReAssignFormB]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_ReAssignFormB]   
(  
 @FB_ID int  
)  
as  
 
begin  
	if exists(SELECT * from tn_FormB where stepComplete=6 and userRegNo is null and FB_ID=@FB_ID)
	BEGIN
		UPDATE tn_FormB SET stepComplete=5,tempRegNo=null,tempRegNo_Date=null,isSubmitted=0,IsReassigned=1 OUTPUT inserted.FB_ID as Retval where FB_ID=@FB_ID
	END
end  
  
GO
/****** Object:  StoredProcedure [dbo].[USP_RecoverPassword]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_RecoverPassword] 
(
	@userId varchar(64),
	@mobileno varchar(10)
)
as

	if exists (select userID from NCB_LoginMaster where userID=@userId and mobileNo=@mobileno and status=1 and deleted=0)
	begin
		select userID,userPass from NCB_LoginMaster where userID=@userId and status=1 and deleted=0
	end
GO
/****** Object:  StoredProcedure [dbo].[USP_RecoverPassword1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[USP_RecoverPassword1] 
(
	@userId varchar(64),
	@mobileno varchar(10)
)
as

	if exists (select userID from NCB_LoginMaster where userID=@userId and mobileNo=@mobileno and status=1 and deleted=0)
	begin
		select userID,userPass1 from NCB_LoginMaster where userID=@userId and status=1 and deleted=0
	end
	
GO
/****** Object:  StoredProcedure [dbo].[USP_Registrant_Export]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_Registrant_Export]
AS
BEGIN
SELECT applicantName,applicantAddress,cityName,pincode,mobileNo,StateName,userRegNo,NatureOfActivity,Substance FROM(
SELECT  FB.applicantName, REPLACE(REPLACE(REPLACE(FB.applicantAddress,char(9),''),char(10),''),char(13),'')applicantAddress, 
FB.cityName, FB.pincode, FB.mobileNo,StateName, FB.userRegNo,
[dbo].[ufn_GetNatureActivityExport](FB.FB_ID)NatureOfActivity,[dbo].[ufn_GetSubstance](FB.FB_ID)Substance
FROM tn_FormB FB INNER JOIN fb_ControlledSubstanceReg CS ON FB.FB_ID = CS.FB_ID INNER JOIN State_Master S ON FB.S_ID=S.S_ID 
WHERE FB.deleted=0 and userRegNo is not null
group by FB.applicantName, FB.applicantAddress, FB.cityName, FB.pincode, FB.mobileNo,StateName, FB.userRegNo,FB.FB_ID,CS_ID
)ds 
group by applicantName,applicantAddress,cityName,pincode,mobileNo,StateName,userRegNo,NatureOfActivity,Substance
END

GO
/****** Object:  StoredProcedure [dbo].[USP_ReportActivity]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_ReportActivity]
(
	@QuarterFrom int,
	@QuarterTo int,
	@CS_ID int=0,
	@ZO_ID int=0,
	@Nature_Activity nvarchar(16)=''
)
as
BEGIN
select ZonalOffice,Name,URN,ControlledSubstance,SUM(Quantity)Quantity,SUM(Quantity2)Quantity2,Nature_Activity from
(
	select returnQuarter FiledQuarter,ZonalOffice,manufacturerName Name,urnNo URN,ControlledSubstance,mfdQauntity Quantity,consignQTY Quantity2,Nature_Activity 
	from UV_ActivityReport_FormE where returnQuarter>=@QuarterFrom and returnQuarter<=@QuarterTo and (CS_ID=@CS_ID or @CS_ID=0) and (ZO_ID=@ZO_ID or @ZO_ID=0) and (Nature_Activity=@Nature_Activity or @Nature_Activity='')
	UNION ALL
	select Quater FiledQuarter,ZonalOffice,Seller_Name Name,URN,ControlledSubstance,Quantity_Received Quantity,0 Quantity2,Nature_Activity 
	from UV_ActivityReport_FormF where Quater>=@QuarterFrom and Quater<=@QuarterTo and (CS_ID=@CS_ID or @CS_ID=0) and (ZO_ID=@ZO_ID or @ZO_ID=0) and (Nature_Activity=@Nature_Activity or @Nature_Activity='')

)dd group by ZonalOffice,Name,URN,ControlledSubstance,Nature_Activity order by ZonalOffice,URN,ControlledSubstance
END
GO
/****** Object:  StoredProcedure [dbo].[USP_ReportIntermediary]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_ReportIntermediary]
(
	@QuarterFrom int=0,
	@QuarterTo int=0,
	@CS_ID int=0,
	@ZO_ID int=0,
	@Nature_Activity int=0,
	@BrokerURN nvarchar(16)='',
	@EnquiredURN nvarchar(16)=''
)
AS
BEGIN
select ZonalOffice,BrokerName,URN,Qtr_Name,ControlledSubstance,EnqURN,SUM(CASE WHEN recordType=1 THEN qty else 0 end) SellerQty,

SUM(CASE WHEN recordType=2 THEN qty else 0 end) BuyerQty 

from UV_FormL where ((returnQuarter>=@QuarterFrom and returnQuarter<=@QuarterTo) OR @QuarterFrom=0) and (ZO_ID=@ZO_ID OR @ZO_ID=0) and

(CS_ID=@CS_ID OR @CS_ID=0) and (recordType=@Nature_Activity OR @Nature_Activity=0) and (URN=@BrokerURN OR @BrokerURN='') and 

(EnqURN=@EnquiredURN OR @EnquiredURN='')

group by ZonalOffice,BrokerName,URN,Qtr_Name,ControlledSubstance,EnqURN

ORDER BY ZonalOffice,BrokerName,Qtr_Name,EnqURN,ControlledSubstance
END
GO
/****** Object:  StoredProcedure [dbo].[USP_ResetAdminPassword1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_ResetAdminPassword1]
(
	@userId varchar(64),
	@oldPass nvarchar(128),
	@newPass nvarchar(128)
)
as

declare @retval varchar(1)
set @retval=0
if exists (select * from NCB_AdminLoginMaster where userID=@userId and userPass1=@oldPass and status=1 and deleted=0)
begin
	update NCB_AdminLoginMaster set userPass1=@newPass where userID=@userId and userPass1=@oldPass and status=1 and deleted=0
	set @retval=1
end

select @retval as ReturnVal
GO
/****** Object:  StoredProcedure [dbo].[USP_ResetPassword]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[USP_ResetPassword]
(
	@userId varchar(64),
	@oldPass varchar(32),
	@newPass varchar(32)
)
as

declare @retval varchar(1)
set @retval=0
if exists (select * from NCB_LoginMaster where userID=@userId and userPass=@oldPass and status=1 and deleted=0)
begin
	update NCB_LoginMaster set userPass=@newPass where userID=@userId and userPass=@oldPass and status=1 and deleted=0
	set @retval=1
end

select @retval as ReturnVal



GO
/****** Object:  StoredProcedure [dbo].[USP_ResetPassword1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_ResetPassword1]
(
	@userId varchar(64),
	@oldPass nvarchar(128),
	@newPass nvarchar(128)
)
as

declare @retval varchar(1)
set @retval=0
if exists (select * from NCB_LoginMaster where userID=@userId and userPass1=@oldPass and status=1 and deleted=0)
begin
	update NCB_LoginMaster set userPass1=@newPass where userID=@userId and userPass1=@oldPass and status=1 and deleted=0
	set @retval=1
end

select @retval as ReturnVal
GO
/****** Object:  StoredProcedure [dbo].[USP_ReturnQuarter]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_ReturnQuarter]
(
	@mode nvarchar(10),
	@URN nvarchar(50),
	@Quarter int,
	@SubURN int,
	@Id int,
	@FiledReturn int=null
)
AS
BEGIN
	if(@mode='UPD')
	BEGIN
		UPDATE Quarter_ReturnFiling SET [quarter]=@Quarter,totalSubURN=@SubURN,ReturnFiled=@FiledReturn OUTPUT inserted.id as retval where URN=@URN and id=@Id
	END
	if(@mode='DLT')
	BEGIN
		DELETE FROM Quarter_ReturnFiling OUTPUT deleted.id as retval where id=@Id
	END
END
GO
/****** Object:  StoredProcedure [dbo].[USP_saveErr]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_saveErr]
(
	@Desc varchar(2000),
	@ErrIn int
)
as
insert into ErLog(LogDESC,EntryDate,ErrIn)values(@Desc,getdate(),@ErrIn)
GO
/****** Object:  StoredProcedure [dbo].[USP_Search_VIEW_QUATER]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_Search_VIEW_QUATER]
@action varchar(250), 
@Qtr_ID int
--@Qtr_Name nvarchar(50)
--@loginId int  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    if(@action = 'Search')
	begin
	Select Qtr_ID,Qtr_Desc,Qtr_Name,	(case when status = 1 then 'images/yes-icon.gif' else 'images/no-icon.gif'end)as statusImage
	from Quater_Master
	where  Qtr_ID like @Qtr_ID  and  deleted = 0
	end
END
GO
/****** Object:  StoredProcedure [dbo].[USP_SubmittedFormList]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_SubmittedFormList]
(
	@LoginId int
)
as
select distinct 'Form E'as Form,'<a href="javascript:void(0);">View</a>'as page from tn_FormE where addBy=@LoginId
union
select distinct 'Form F'as Form,'<a href="javascript:void(0);">View</a>'as page from tn_FormF where addBy=@LoginId
union
select distinct 'Form G'as Form,'<a href="javascript:void(0);">View</a>'as page from tn_FormG where addBy=@LoginId
union
select distinct 'Form H'as Form,'<a href="javascript:void(0);">View</a>'as page from tn_FormH where addBy=@LoginId
union
select distinct 'Form I'as Form,'<a href="javascript:void(0);">View</a>'as page from tn_FormI where addBy=@LoginId
GO
/****** Object:  StoredProcedure [dbo].[USP_UPD_SubURN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_UPD_SubURN]
(  
 @FB_ID int
)  
as  
SET NOCOUNT ON;       
BEGIN TRAN   
declare @urn varchar(20)
select @urn=userRegNo FROM tn_FormB where FB_ID=@FB_ID

if exists(select * from SubURN where parentURN=@urn and deleted=0)
BEGIN
	UPDATE  SubURN SET deleted=1 where parentURN=@urn and deleted=0
END

if(select COUNT(distinct(premisesAddress)) from fb_ControlledSubstanceReg where deleted=0 and FB_ID=@FB_ID)>1
BEGIN
	UPDATE SubURN SET deleted=1 where parentURN=@urn
	declare @tbl as table(id int identity(1,1),premisesAddress nvarchar(256))
	INSERT INTO @tbl(premisesAddress) select distinct(premisesAddress) from fb_ControlledSubstanceReg where deleted=0 and FB_ID=@FB_ID
	declare @count int=1
	if((select COUNT(1) from @tbl)>1)
	BEGIN
	WHILE(select COUNT(1) from @tbl)>=@count
	BEGIN
		declare @PD_ID nvarchar(400)
		--select @PD_ID=COALESCE(''+@PD_ID+''',''','')+convert(varchar,PD_ID) from fb_ControlledSubstanceReg where premisesAddress=(select premisesAddress from @tbl where id=@count)	
		if not exists(SELECT * from SubURN WHERE parentURN=@urn and PremiseAddress=(select premisesAddress from @tbl where id=@count))
		begin
			select @PD_ID=COALESCE(@PD_ID+',','')+convert(varchar,PD_ID) from fb_ControlledSubstanceReg where premisesAddress=(select premisesAddress from @tbl where id=@count)	
			declare @returncode1 nvarchar(50)  
			exec USP_GET_SubURN @FB_ID,@PD_ID,@returncode1 OUTPUT
			INSERT INTO SubURN(parentURN,subURN,FB_ID,PremiseAddress) SELECT @urn,'SUB'+CAST(@returncode1 as nvarchar),@FB_ID,premisesAddress from @tbl where id=@count
		END
		else
		BEGIN
			UPDATE SubURN SET deleted=0 where parentURN=@urn and id=(select TOP 1 id from SubURN where PremiseAddress=(select premisesAddress from @tbl where id=@count) order by id desc)
		END
		set @count=@count+1
		
	END
	END
	if(@count>1)
	BEGIN
		declare @qtr int=0
		if exists(select * from tn_FormF where URN=@urn)
		BEGIN
			select @qtr=Quater+1 from tn_FormF where URN=@urn
		END
		else if exists(select * from tn_FormE where urnNo=@urn)
		BEGIN
			select @qtr=returnQuarter+1 from tn_FormE where urnNo=@urn
		END
		else
		BEGIN
			 declare @Qtr_Name varchar(50)  
			   select @Qtr_Name='Q'+cast(qtr as varchar)+' '+ cast(returnyear as varchar)+' - '+
			   CAst(case when qtr=1 then 'Jan-March' when qtr=2 then 'April-June' when qtr=3 then 'July-Sept' when qtr=4 then 'Oct-Dec' else '' end as varchar)    
			  from  
			  (  
			  select (case when DATEPART(month,userRegNo_IssueDT) between 1 and 3 then 1   
				 when DATEPART(month,userRegNo_IssueDT)between 4 and 6 then 2  
				 when DATEPART(month,userRegNo_IssueDT)between 7 and 9 then 3  
				 when DATEPART(month,userRegNo_IssueDT)between 10 and 12 then 4 else '' end)qtr,  
				 DATEPART(YEAR,userRegNo_IssueDT)returnyear  
			  from tn_FormB where FB_ID=@FB_ID and deleted=0  
			  )tmp;  
			  select @qtr=Qtr_ID from Quater_Master where Qtr_Name=@Qtr_Name 
		END
		IF EXISTS(SELECT * FROM Quarter_ReturnFiling where URN=@urn)
		BEGIN
			UPDATE Quarter_ReturnFiling SET totalSubURN=@count-1,[quarter]=@qtr where URN=@urn
		END
		ELSE
		BEGIN
			INSERT Quarter_ReturnFiling(URN,totalSubURN,[quarter]) values(@urn,@count-1,@qtr)
		END
	END
END
  
IF @@ERROR <> 0 BEGIN GOTO ErrHld END               
 COMMIT TRAN            
 SELECT 0 Ret_Value       
 RETURN (0)          
         
      
ErrHld:          
ROLLBACK TRAN           
RETURN (1)
GO
/****** Object:  StoredProcedure [dbo].[USP_Update_UserAccess]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_Update_UserAccess]
 (
	@userid nvarchar(64),
	@token nvarchar(128)
 )
 AS
 BEGIN
	UPDATE NCB_LoginMaster SET sessionId=@token,sessionDate=GETDATE() where userID=@userid
 END
GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateFormA]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[USP_UpdateFormA]
(
@FB_ID int,
@LoginID int

)as
begin

update tn_FormB set fa_Generate_Status='Yes',fa_Generate_By=@LoginID,
fa_Generate_Date=GETDATE() where FB_ID=@FB_ID

end
GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateUserAccess]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROC [dbo].[USP_UpdateUserAccess]
 (
	@userid nvarchar(64),
	@token nvarchar(128)
 )
 AS
 BEGIN
	UPDATE NCB_AdminLoginMaster SET sessionId=@token,sessionDate=GETDATE() where userID=@userid
 END
GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateZone]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_UpdateZone]
(
	@ZO_ID int,
	@ZoneName nvarchar(100),
	@ZoneAddress nvarchar(4000),
	@loginID int
)
as
begin
	update ZonalOffice_Master set ZonalOffice=@ZoneName,ZonalAddress=@ZoneAddress,Edit_By=@loginID,Edit_Date=GETDATE() output inserted.ZO_ID as Retval where ZO_ID=@ZO_ID
end
GO
/****** Object:  StoredProcedure [dbo].[USP_URN_CompanyReport]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_URN_CompanyReport]
(
	@QuarterFrom int,
	@QuarterTo int,
	@CS_ID int=0,
	@Name nvarchar(128)=''
)
as
BEGIN
select ZonalOffice,Name,URN,SUM(Quantity)Quantity,SUM(Quantity2)Quantity2,SUM(Quantity3)Quantity3,SUM(Quantity4)Quantity4 from
(
select ZonalOffice,manufacturerName Name,urnNo URN,mfdQauntity Quantity,consignQTY Quantity2,0 Quantity3,0 Quantity4
from UV_ActivityReport_FormE where returnQuarter>=@QuarterFrom and returnQuarter<=@QuarterTo and (CS_ID=@CS_ID or @CS_ID=0) and (urnNo like '%'+@Name+'%' or manufacturerName like '%'+@Name+'%' or @Name='')
UNION ALL
select ZonalOffice,Seller_Name Name,URN,0 Quantity,(CASE WHEN Nature_Activity='Sale' or Nature_Activity='Export' or Nature_Activity='Distribution' then Quantity_Received else 0 end)Quantity2,
	(CASE WHEN Nature_Activity='Consumption' then Quantity_Received else 0 end)Quantity3,(CASE WHEN Nature_Activity='Purchase' then Quantity_Received else 0 end)Quantity4
from UV_ActivityReport_FormF where Quater>=@QuarterFrom and Quater<=@QuarterTo and (CS_ID=@CS_ID or @CS_ID=0) and (URN like '%'+@Name+'%' or Seller_Name like '%'+@Name+'%' or @Name='')
)dd group by ZonalOffice,Name,URN order by Name,ZonalOffice,URN
END
GO
/****** Object:  StoredProcedure [dbo].[USP_URNQuantityReport]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_URNQuantityReport]  
(  
 @report varchar(20),  
 @ZO_ID int=0  
)  
as  
if @report='MFDQTY'  
begin  
 select fb.FB_ID,fb.userRegNo,fb.applicantName,dbo.ufn_MaserDataName(fb.FB_ID)SubStanceName,sm.StateName,  
 zm.ZonalOffice,isnull((select mfdQauntity from UV_MFDQTY where FB_ID=fb.FB_ID),0)QTY  
 from tn_FormB fb inner join State_Master sm ON fb.S_ID=sm.S_ID   
 inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID where fb.userRegNo is not null  
end  
if @report='SOLDQTY'  
begin  
 select fb.FB_ID,fb.userRegNo,fb.applicantName,dbo.ufn_MaserDataName(fb.FB_ID)SubStanceName,sm.StateName,  
 zm.ZonalOffice,isnull((select consignQTY from UV_SaleQTY where FB_ID=fb.FB_ID),0)QTY  
 from tn_FormB fb inner join State_Master sm ON fb.S_ID=sm.S_ID   
 inner join ZonalOffice_Master zm ON fb.ZO_ID=zm.ZO_ID where fb.userRegNo is not null  
end
GO
/****** Object:  StoredProcedure [dbo].[USP_User_Login]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_User_Login]     
(        
	@userID nvarchar(64),        
	@userPassword nvarchar(32)      
)        
as         
 begin      
 select loginID,userID,applicantName,applyingName from  NCB_LoginMaster where userID=@userID  
 and userPass=@userPassword and Status=1 and deleted=0 and accType='user'       
 end  
GO
/****** Object:  StoredProcedure [dbo].[USP_User_Login1]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_User_Login1]     
(        
	@userID nvarchar(64),        
	@userPassword nvarchar(256)      
)        
as         
 begin
declare @pass nvarchar(128)
select @pass=ltrim(replace(RIGHT(@userPassword,CHARINDEX(':',reverse(@userPassword),1)),':',''))
	select loginID,userID,applicantName,applyingName,CASE WHEN DATEDIFF(minute,SessionDate,GetDate())<45 THEN 'Y' else 'N' END Session_Date
	from  NCB_LoginMaster where userID=@userID and userPass1=@pass and Status=1 and deleted=0 and accType='user'       
end 
GO
/****** Object:  StoredProcedure [dbo].[USP_UserVerification]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[USP_UserVerification]
(
	@ID int,
	@email varchar(64),
	@verID nvarchar(128)
)
as
Declare @Return varchar(1)
set @Return='2'
if exists (select loginID from NCB_LoginMaster where loginID=@ID and userID=@email and verficationID=@verID and status=1 and deleted=0)
	begin
		set @Return='0'
		select @Return as Retvalue
	end
else if exists (select loginID from NCB_LoginMaster where loginID=@ID and userID=@email and verficationID=@verID and status=0 and deleted=0)
	begin
		Update NCB_LoginMaster set status=1 where loginID=@ID
		set @Return='1'
		select @Return as Retvalue
		select applicantName,emailID,userID,userPass1 from ncb_loginMaster where Status=1 and Deleted=0 and loginID=@ID
	end
GO
/****** Object:  StoredProcedure [dbo].[USP_ValidateAdminUser]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE PROC [dbo].[USP_ValidateAdminUser]
 (
	@userid nvarchar(64),
	@token nvarchar(128)
 )
 AS
 BEGIN
	if exists(SELECT * from NCB_AdminLoginMaster where userID=@userid and sessionId=@token)
	BEGIN
		select 1 Retval, 'valid' msg
	END
	else
	BEGIN
		select 0 Retval,'invalid' msg
	END
 END
GO
/****** Object:  StoredProcedure [dbo].[USP_ValidateURN]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_ValidateURN]
(
@consignorReg varchar(50),
@consigneeReg varchar(50),
@action varchar(250)
)
	
AS
BEGIN
	if(@action= 'OutSideZone')
	begin
		select top 1 * from tn_FormB where userRegNo <> @consignorReg and userRegNo = @consigneeReg and
		ZO_ID not in (select ZO_ID from tn_FormB  where userRegNo = @consignorReg)
	end
	
	else if(@action= 'ValidURN')
	begin
		select top 1 * from tn_FormB where userRegNo = @consigneeReg
	end
	
	if(@action= 'WithinZone')
	begin
		select top 1 * from tn_FormB where userRegNo <> @consignorReg and userRegNo = @consigneeReg and 
		ZO_ID in (select ZO_ID from tn_FormB  where userRegNo = @consignorReg)
	end
	
END
GO
/****** Object:  StoredProcedure [dbo].[USP_ValidateUser]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[USP_ValidateUser]
 (
	@userid nvarchar(64),
	@token nvarchar(128)
 )
 AS
 BEGIN
	if exists(SELECT * from NCB_LoginMaster where userID=@userid and sessionId=@token)
	BEGIN
		select 1 Retval, 'valid' msg
	END
	else
	BEGIN
		select 0 Retval,'invalid' msg
	END
 END
GO
/****** Object:  StoredProcedure [dbo].[USP_VIEWQUATER_SELECT]    Script Date: 3/13/2024 2:23:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_VIEWQUATER_SELECT]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
	Select Qtr_ID,Qtr_Name,Qtr_Desc,editDate,	(case when status = 1 then 'images/yes-icon.gif' else 'images/no-icon.gif'end)as statusImage
	from Quater_Master
	where deleted = 0 order by Qtr_ID DESC
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "BM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "LM"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AM1"
            Begin Extent = 
               Top = 138
               Left = 246
               Bottom = 268
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AM2"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SM"
            Begin Extent = 
               Top = 270
               Left = 246
               Bottom = 400
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ZM"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 117' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_RegistrantList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_RegistrantList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_RegistrantList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "BM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "LM"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AM1"
            Begin Extent = 
               Top = 138
               Left = 246
               Bottom = 268
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AM2"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SM"
            Begin Extent = 
               Top = 270
               Left = 246
               Bottom = 400
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ZM"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 117' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_RegistrantRecord'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_RegistrantRecord'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_RegistrantRecord'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "LM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_UserList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'UV_UserList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ff_Receipt_Import"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tn_FormF"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 136
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ControlledSubstance_Master"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_SubstancesQtyUrnWise'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_SubstancesQtyUrnWise'
GO
