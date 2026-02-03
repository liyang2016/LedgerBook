import { DataManager, Transaction } from '../services/DataManager'
import { BottomNavBar } from '../components/BottomNavBar'
import router from '@ohos.router'

interface CategoryStat {
  category: string
  amount: number
  percentage: number
}

@Entry
@Component
struct StatisticsPage {
  @State currentTab: 'expense' | 'income' = 'expense'
  @State expenseStats: CategoryStat[] = []
  @State incomeStats: CategoryStat[] = []
  @State totalExpense: number = 0
  @State totalIncome: number = 0
  private dataManager: DataManager = DataManager.getInstance()

  async aboutToAppear(): Promise<void> {
    await this.loadStatistics()
  }

  async loadStatistics(): Promise<void> {
    const transactions = await this.dataManager.getTransactions()
    
    this.calculateExpenseStats(transactions)
    this.calculateIncomeStats(transactions)
  }

  calculateExpenseStats(transactions: Transaction[]): void {
    const expenseTransactions = transactions.filter(t => t.type === 'expense')
    this.totalExpense = expenseTransactions.reduce((sum, t) => sum + t.amount, 0)

    const categoryMap: Map<string, number> = new Map()
    expenseTransactions.forEach(t => {
      const current = categoryMap.get(t.category) || 0
      categoryMap.set(t.category, current + t.amount)
    })

    this.expenseStats = Array.from(categoryMap.entries()).map((entry: [string, number]) => {
      const category = entry[0]
      const amount = entry[1]
      return {
        category: category,
        amount: amount,
        percentage: this.totalExpense > 0 ? (amount / this.totalExpense) * 100 : 0
      } as CategoryStat
    }).sort((a, b) => b.amount - a.amount)
  }

  calculateIncomeStats(transactions: Transaction[]): void {
    const incomeTransactions = transactions.filter(t => t.type === 'income')
    this.totalIncome = incomeTransactions.reduce((sum, t) => sum + t.amount, 0)

    const categoryMap: Map<string, number> = new Map()
    incomeTransactions.forEach(t => {
      const current = categoryMap.get(t.category) || 0
      categoryMap.set(t.category, current + t.amount)
    })

    this.incomeStats = Array.from(categoryMap.entries()).map((entry: [string, number]) => {
      const category = entry[0]
      const amount = entry[1]
      return {
        category: category,
        amount: amount,
        percentage: this.totalIncome > 0 ? (amount / this.totalIncome) * 100 : 0
      } as CategoryStat
    }).sort((a, b) => b.amount - a.amount)
  }

  getCurrentStats(): CategoryStat[] {
    return this.currentTab === 'expense' ? this.expenseStats : this.incomeStats
  }

  getCurrentTotal(): number {
    return this.currentTab === 'expense' ? this.totalExpense : this.totalIncome
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('统计分析')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')

        Row() {
          Button('支出')
            .width('48%')
            .height(40)
            .backgroundColor(this.currentTab === 'expense' ? '#F44336' : '#F0F0F0')
            .fontColor(this.currentTab === 'expense' ? '#FFFFFF' : '#757575')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(6)
            .onClick(() => {
              this.currentTab = 'expense'
            })

          Button('收入')
            .width('48%')
            .height(40)
            .backgroundColor(this.currentTab === 'income' ? '#4CAF50' : '#F0F0F0')
            .fontColor(this.currentTab === 'income' ? '#FFFFFF' : '#757575')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .borderRadius(6)
            .onClick(() => {
              this.currentTab = 'income'
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .justifyContent(FlexAlign.SpaceBetween)

        Column() {
          Text('¥' + this.getCurrentTotal().toFixed(2))
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.currentTab === 'expense' ? '#F44336' : '#4CAF50')
            .margin({ top: 24, bottom: 8 })

          Text(this.currentTab === 'expense' ? '总支出' : '总收入')
            .fontSize(13)
            .fontColor('#757575')
        }
        .width('100%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .margin({ left: 16, right: 16, top: 12 })
        .borderRadius(8)

        Column() {
          Text('分类排行')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .width('100%')
            .margin({ bottom: 20 })

          if (this.getCurrentStats().length === 0) {
            Column() {
              Text('暂无数据')
                .fontSize(16)
                .fontColor('#9E9E9E')
                .margin({ top: 40 })
            }
            .width('100%')
            .layoutWeight(1)
          } else {
            List({ space: 8 }) {
              ForEach(this.getCurrentStats(), (stat: CategoryStat, index: number) => {
                ListItem() {
                  this.StatItem(stat, index)
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding(24)
        .backgroundColor('#FFFFFF')
        .margin({ left: 16, right: 16, top: 12, bottom: 16 })
        .borderRadius(8)
        
        // 底部导航栏占位
        Blank()
          .height(56)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFAFA')

      // 底部导航栏固定在底部
      Column() {
        BottomNavBar({ currentPageIndex: 1 })
      }
      .width('100%')
      .height(56)
      .position({ x: 0, y: '100%' })
      .translate({ y: -56 })
      .zIndex(100)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatItem(stat: CategoryStat, index: number) {
    Column() {
      Row() {
        Row() {
          Text((index + 1).toString())
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width(26)
            .height(26)
            .textAlign(TextAlign.Center)
            .backgroundColor(index < 3 ? '#2196F3' : '#9E9E9E')
            .borderRadius(4)

          Text(stat.category)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .margin({ left: 12 })
        }

        Blank()

        Text('¥' + stat.amount.toFixed(2))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTab === 'expense' ? '#F44336' : '#4CAF50')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Stack() {
        Row()
          .width('100%')
          .height(6)
          .backgroundColor('#EEEEEE')
          .borderRadius(0)

        Row()
          .width(stat.percentage + '%')
          .height(6)
          .backgroundColor(this.currentTab === 'expense' ? '#F44336' : '#4CAF50')
          .borderRadius(0)
      }
      .width('100%')

      Row() {
        Text(stat.percentage.toFixed(1) + '%')
          .fontSize(11)
          .fontColor('#757575')
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F5F5F5')
    .borderRadius(6)
    .border({ width: 1, color: '#EEEEEE' })
  }
}
