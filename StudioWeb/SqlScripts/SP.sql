

-- testo se il parametro di tipo uniqueidentifier è null
create procedure test_proc
	@Id				uniqueidentifier

AS
BEGIN

	IF @Id IS NULL
		print 'ID is null'
	ELSE
		print 'ID is NOT null'

END

 EXEC test_proc null



 


CREATE FUNCTION NullIfEmptyGuid 
( 
    @guidValue uniqueidentifier 
) 
RETURNS uniqueidentifier 
AS 
BEGIN 
    declare @result uniqueidentifier 
    declare @emptyGuid uniqueidentifier 
    set @emptyGuid = cast(cast(0 as binary) as uniqueidentifier)


    select @result = case when @guidValue = @emptyGuid then null else @guidValue end

    RETURN @result
END 
GO