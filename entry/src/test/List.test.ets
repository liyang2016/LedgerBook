import DataManagerUnifiedTest from './__tests__/DataManagerUnifiedTest';
import TransactionUtilsTest from './TransactionUtils.test';
import StatisticsCalculatorTest from './StatisticsCalculator.test';

export default function testsuite() {
  DataManagerUnifiedTest();
  TransactionUtilsTest();
  StatisticsCalculatorTest();
}
