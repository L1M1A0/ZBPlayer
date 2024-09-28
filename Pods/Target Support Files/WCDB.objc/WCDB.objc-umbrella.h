#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WCDBObjc.h"
#import "Interface.h"
#import "WCTCommon.h"
#import "WCTConvertible.h"
#import "WCTDatabase+Test.h"
#import "WCTDatabase+Version.h"
#import "WCTDeclaration.h"
#import "WCTFoundation.h"
#import "WCTFTSTokenizerUtil.h"
#import "WCTOptional.h"
#import "WCTTag.h"
#import "WCTValue.h"
#import "NSData+WCTColumnCoding.h"
#import "NSDate+WCTColumnCoding.h"
#import "NSNull+WCTColumnCoding.h"
#import "NSNumber+WCTColumnCoding.h"
#import "NSObject+WCTColumnCoding.h"
#import "NSString+WCTColumnCoding.h"
#import "WCTBuiltin.h"
#import "WCTMaster+WCTTableCoding.h"
#import "WCTMaster.h"
#import "WCTSequence+WCTTableCoding.h"
#import "WCTSequence.h"
#import "WCTPreparedStatement.h"
#import "WCTDatabase+Migration.h"
#import "WCTMigrationInfo.h"
#import "WCTDatabase+Compression.h"
#import "WCTCompressionInfo.h"
#import "WCTDatabase+Transaction.h"
#import "WCTHandle+Transaction.h"
#import "WCTTransaction.h"
#import "WCTDatabase+Handle.h"
#import "WCTHandle.h"
#import "WCTCancellationSignal.h"
#import "WCTDatabase+FTS.h"
#import "WCTError.h"
#import "WCTDatabase+Monitor.h"
#import "WCTPerformanceInfo.h"
#import "WCTInsert.h"
#import "WCTDelete.h"
#import "WCTUpdate.h"
#import "WCTSelectable.h"
#import "WCTSelect.h"
#import "WCTMultiSelect.h"
#import "WCTHandle+ChainCall.h"
#import "WCTTable+ChainCall.h"
#import "WCTDatabase+ChainCall.h"
#import "WCTChainCall.h"
#import "WCTConvenient.h"
#import "WCTDatabase+Convenient.h"
#import "WCTHandle+Convenient.h"
#import "WCTTable+Convenient.h"
#import "WCTDatabase.h"
#import "WCTDatabase+File.h"
#import "WCTDatabase+Repair.h"
#import "WCTDatabase+Config.h"
#import "WCTDatabase+Memory.h"
#import "WCTORM.h"
#import "WCTBaseAccessor.h"
#import "WCTCppAccessor.h"
#import "WCTObjCAccessor.h"
#import "WCTRuntimeBaseAccessor.h"
#import "WCTRuntimeCppAccessor.h"
#import "WCTRuntimeObjCAccessor.h"
#import "WCTBinding.h"
#import "WCTColumnBinding.h"
#import "WCTColumnCoding.h"
#import "WCTProperty.h"
#import "WCTResultColumn.h"
#import "WCTTableCoding.h"
#import "WCTColumnConstraintMacro.h"
#import "WCTIndexMacro.h"
#import "WCTMacro.h"
#import "WCTMacroUtility.h"
#import "WCTPropertyMacro.h"
#import "WCTTableConstraintMacro.h"
#import "WCTVirtualTableMacro.h"
#import "WCTTable.h"
#import "WCTTableProtocol.h"
#import "WCTTable+Table.h"
#import "WCTDatabase+Table.h"
#import "WCTHandle+Table.h"
#import "WCTBridgeProperty.h"
#import "WCTBridgeProperty+CPP.h"
#import "SQL.hpp"
#import "Statement.hpp"
#import "WINQ.h"
#import "AggregateFunction.hpp"
#import "BaseBinding.hpp"
#import "ColumnType.hpp"
#import "Convertible.hpp"
#import "ConvertibleImplementation.hpp"
#import "CoreFunction.hpp"
#import "ExpressionOperable.hpp"
#import "FTSFunction.hpp"
#import "SyntaxForwardDeclaration.h"
#import "SyntaxList.hpp"
#import "Value.hpp"
#import "ValueArray.hpp"
#import "BindParameter.hpp"
#import "Column.hpp"
#import "ColumnConstraint.hpp"
#import "ColumnDef.hpp"
#import "CommonTableExpression.hpp"
#import "Expression.hpp"
#import "Filter.hpp"
#import "ForeignKey.hpp"
#import "FrameSpec.hpp"
#import "IndexedColumn.hpp"
#import "Join.hpp"
#import "JoinConstraint.hpp"
#import "LiteralValue.hpp"
#import "OrderingTerm.hpp"
#import "Pragma.hpp"
#import "QualifiedTable.hpp"
#import "RaiseFunction.hpp"
#import "ResultColumn.hpp"
#import "Schema.hpp"
#import "TableConstraint.hpp"
#import "TableOrSubquery.hpp"
#import "Upsert.hpp"
#import "WindowDef.hpp"
#import "StatementAlterTable.hpp"
#import "StatementAnalyze.hpp"
#import "StatementAttach.hpp"
#import "StatementBegin.hpp"
#import "StatementCommit.hpp"
#import "StatementCreateIndex.hpp"
#import "StatementCreateTable.hpp"
#import "StatementCreateTrigger.hpp"
#import "StatementCreateView.hpp"
#import "StatementCreateVirtualTable.hpp"
#import "StatementDelete.hpp"
#import "StatementDetach.hpp"
#import "StatementDropIndex.hpp"
#import "StatementDropTable.hpp"
#import "StatementDropTrigger.hpp"
#import "StatementDropView.hpp"
#import "StatementExplain.hpp"
#import "StatementInsert.hpp"
#import "StatementPragma.hpp"
#import "StatementReindex.hpp"
#import "StatementRelease.hpp"
#import "StatementRollback.hpp"
#import "StatementSavepoint.hpp"
#import "StatementSelect.hpp"
#import "StatementUpdate.hpp"
#import "StatementVacuum.hpp"
#import "SyntaxCommonConst.hpp"
#import "SyntaxBindParameter.hpp"
#import "SyntaxColumn.hpp"
#import "SyntaxColumnConstraint.hpp"
#import "SyntaxColumnDef.hpp"
#import "SyntaxCommonTableExpression.hpp"
#import "SyntaxExpression.hpp"
#import "SyntaxFilter.hpp"
#import "SyntaxForeignKeyClause.hpp"
#import "SyntaxFrameSpec.hpp"
#import "SyntaxIdentifier.hpp"
#import "SyntaxIndexedColumn.hpp"
#import "SyntaxJoinClause.hpp"
#import "SyntaxJoinConstraint.hpp"
#import "SyntaxLiteralValue.hpp"
#import "SyntaxOrderingTerm.hpp"
#import "SyntaxPragma.hpp"
#import "SyntaxQualifiedTableName.hpp"
#import "SyntaxRaiseFunction.hpp"
#import "SyntaxResultColumn.hpp"
#import "SyntaxSchema.hpp"
#import "SyntaxSelectCore.hpp"
#import "SyntaxTableConstraint.hpp"
#import "SyntaxTableOrSubquery.hpp"
#import "SyntaxUpsertClause.hpp"
#import "SyntaxWindowDef.hpp"
#import "SyntaxAlterTableSTMT.hpp"
#import "SyntaxAnalyzeSTMT.hpp"
#import "SyntaxAttachSTMT.hpp"
#import "SyntaxBeginSTMT.hpp"
#import "SyntaxCommitSTMT.hpp"
#import "SyntaxCreateIndexSTMT.hpp"
#import "SyntaxCreateTableSTMT.hpp"
#import "SyntaxCreateTriggerSTMT.hpp"
#import "SyntaxCreateViewSTMT.hpp"
#import "SyntaxCreateVirtualTableSTMT.hpp"
#import "SyntaxDeleteSTMT.hpp"
#import "SyntaxDetachSTMT.hpp"
#import "SyntaxDropIndexSTMT.hpp"
#import "SyntaxDropTableSTMT.hpp"
#import "SyntaxDropTriggerSTMT.hpp"
#import "SyntaxDropViewSTMT.hpp"
#import "SyntaxExplainSTMT.hpp"
#import "SyntaxInsertSTMT.hpp"
#import "SyntaxPragmaSTMT.hpp"
#import "SyntaxReindexSTMT.hpp"
#import "SyntaxReleaseSTMT.hpp"
#import "SyntaxRollbackSTMT.hpp"
#import "SyntaxSavepointSTMT.hpp"
#import "SyntaxSelectSTMT.hpp"
#import "SyntaxUpdateSTMT.hpp"
#import "SyntaxVacuumSTMT.hpp"
#import "Syntax.h"
#import "SyntaxAssertion.hpp"
#import "SyntaxEnum.hpp"
#import "SysTypes.h"
#import "Shadow.hpp"
#import "Macro.h"
#import "CaseInsensitiveList.hpp"
#import "ScalarFunctionModule.hpp"
#import "ScalarFunctionTemplate.hpp"
#import "TokenizerModule.hpp"
#import "TokenizerModuleTemplate.hpp"
#import "BaseTokenizerUtil.hpp"
#import "PinyinTokenizer.hpp"
#import "OneOrBinaryTokenizer.hpp"
#import "FTS5AuxiliaryFunctionTemplate.hpp"
#import "AuxiliaryFunctionModule.hpp"
#import "SubstringMatchInfo.hpp"
#import "FTSError.hpp"
#import "RecyclableHandle.hpp"
#import "Tag.hpp"
#import "Recyclable.hpp"
#import "SharedThreadedErrorProne.hpp"
#import "StringView.hpp"
#import "WCDBOptional.hpp"
#import "WCDBError.hpp"
#import "Data.hpp"
#import "UnsafeData.hpp"
#import "MemberPointer.hpp"

FOUNDATION_EXPORT double WCDBObjcVersionNumber;
FOUNDATION_EXPORT const unsigned char WCDBObjcVersionString[];
