import { DataManager, Transaction } from '../services/DataManager'
import { AddTransactionDialog } from '../components/AddTransactionDialog'
import { EditTransactionDialog } from '../components/EditTransactionDialog'
import { BottomNavBar } from '../components/BottomNavBar'
import router from '@ohos.router'

@Entry
@Component
struct Index {
  @State balance: number = 0
  @State totalIncome: number = 0
  @State totalExpense: number = 0
  @State transactions: Transaction[] = []
  @State filteredTransactions: Transaction[] = []
  @State isLoading: boolean = true
  @State selectedType: 'all' | 'income' | 'expense' = 'all'
  @State selectedCategory: string = 'all'
  @State selectedDateRange: string = 'all'
  @State showFilterDialog: boolean = false
  @State listOpacity: number = 0
  @State buttonScale: number = 1
  private dataManager: DataManager = DataManager.getInstance()
  private dialogController: CustomDialogController | null = null

  async aboutToAppear(): Promise<void> {
    await this.dataManager.init(getContext(this))
    await this.loadData()
    this.isLoading = false
  }

  async loadData(): Promise<void> {
    this.transactions = await this.dataManager.getTransactions()
    const summary = await this.dataManager.calculateBalance()
    
    animateTo({ duration: 500, curve: Curve.EaseInOut }, () => {
      this.balance = summary.balance
      this.totalIncome = summary.totalIncome
      this.totalExpense = summary.totalExpense
    })
    
    this.applyFilters()
    
    animateTo({ duration: 300, curve: Curve.FastOutSlowIn }, () => {
      this.listOpacity = 1
    })
  }

  applyFilters(): void {
    let filtered = [...this.transactions]

    if (this.selectedType !== 'all') {
      filtered = filtered.filter(t => t.type === this.selectedType)
    }

    if (this.selectedCategory !== 'all') {
      filtered = filtered.filter(t => t.category === this.selectedCategory)
    }

    if (this.selectedDateRange !== 'all') {
      const now = new Date()
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
      
      filtered = filtered.filter(t => {
        const transactionDate = new Date(t.date)
        
        if (this.selectedDateRange === 'today') {
          return transactionDate >= today
        } else if (this.selectedDateRange === 'week') {
          const weekAgo = new Date(today)
          weekAgo.setDate(weekAgo.getDate() - 7)
          return transactionDate >= weekAgo
        } else if (this.selectedDateRange === 'month') {
          const monthAgo = new Date(today)
          monthAgo.setMonth(monthAgo.getMonth() - 1)
          return transactionDate >= monthAgo
        }
        
        return true
      })
    }

    this.filteredTransactions = filtered
  }

  showAddDialog(): void {
    this.dialogController = new CustomDialogController({
      builder: AddTransactionDialog({
        onTransactionAdded: async () => {
          await this.loadData()
        }
      }),
      customStyle: true,
      alignment: DialogAlignment.Center
    })
    this.dialogController.open()
  }

  showEditDialog(transaction: Transaction): void {
    this.dialogController = new CustomDialogController({
      builder: EditTransactionDialog({
        transaction: transaction,
        onTransactionUpdated: async () => {
          await this.loadData()
        }
      }),
      customStyle: true,
      alignment: DialogAlignment.Center
    })
    this.dialogController.open()
  }

  async deleteTransaction(id: number): Promise<void> {
    const success = await this.dataManager.deleteTransaction(id)
    if (success) {
      await this.loadData()
    }
  }

  build() {
    Stack() {
      Column() {
        this.Header()
        this.SummaryCards()
        this.ChartSection()
        this.TransactionList()
        
        // 底部导航栏占位
        Blank()
          .height(56)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFAFA')

      if (this.showFilterDialog) {
        this.FilterDialog()
      }

      // 底部导航栏固定在底部（最上层）
      Column() {
        BottomNavBar({ currentPageIndex: 0 })
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
  Header() {
    Row() {
      Column() {
        Text('我的账本')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Text('让记账变得简单')
          .fontSize(14)
          .fontColor('#9E9E9E')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Row() {
        Button() {
          Text('+')
            .fontSize(28)
            .fontColor('#FFFFFF')
        }
        .width(48)
        .height(48)
        .backgroundColor('#2196F3')
        .borderRadius(8)
        .scale({ x: this.buttonScale, y: this.buttonScale })
        .onClick(() => {
          animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
            this.buttonScale = 0.9
          })
          setTimeout(() => {
            animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
              this.buttonScale = 1
            })
          }, 200)
          this.showAddDialog()
        })
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 20, bottom: 20 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  SummaryCards() {
    Column() {
      Row() {
        Text('账户余额')
          .fontSize(13)
          .fontColor('#757575')
        Blank()
        Text('¥' + this.balance.toFixed(2))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 24, bottom: 20 })

      Row() {
        this.StatCard('总收入', this.totalIncome, '#4CAF50')
        this.StatCard('总支出', this.totalExpense, '#F44336')
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 24 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 12, left: 16, right: 16 })
    .borderRadius(8)
  }

  @Builder
  StatCard(label: string, amount: number, color: string) {
    Row() {
      Column() {
        Text(label)
          .fontSize(12)
          .fontColor('#757575')
        Text('¥' + amount.toFixed(2))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(color)
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Column() {
        Text('●')
          .fontSize(24)
          .fontColor(color)
      }
    }
    .width('48%')
    .padding(16)
    .backgroundColor('#F5F5F5')
    .borderRadius(6)
  }

  @Builder
  ChartSection() {
    Column() {
      Row() {
        Text('本月收支')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Blank()
        Text('查看详情')
          .fontSize(14)
          .fontColor('#2196F3')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/StatisticsPage'
            })
          })
      }
      .width('100%')
      .margin({ bottom: 24 })

      Row() {
        Column() {
          Text('收入占比')
            .fontSize(12)
            .fontColor('#757575')
            .margin({ bottom: 12 })
          this.ProgressBar('收入', this.totalIncome, this.totalIncome + this.totalExpense, '#4CAF50')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('支出占比')
            .fontSize(12)
            .fontColor('#757575')
            .margin({ bottom: 12 })
          this.ProgressBar('支出', this.totalExpense, this.totalIncome + this.totalExpense, '#F44336')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 24 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .margin({ top: 12, left: 16, right: 16 })
    .borderRadius(8)
  }

  @Builder
  ProgressBar(label: string, value: number, total: number, color: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(11)
          .fontColor('#1A1A1A')
        Blank()
        Text(((value / total) * 100).toFixed(0) + '%')
          .fontSize(11)
          .fontColor('#757575')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Stack() {
        Row()
          .width('100%')
          .height(6)
          .backgroundColor('#EEEEEE')
          .borderRadius(0)

        Row()
          .width(((value / total) * 100) + '%')
          .height(6)
          .backgroundColor(color)
          .borderRadius(0)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  TransactionList() {
    Column() {
      Row() {
        Text('最近账单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Blank()
        Button() {
          Text('筛选')
            .fontSize(14)
            .fontColor('#2196F3')
        }
        .backgroundColor('#F0F0F0')
        .height(36)
        .padding({ left: 16, right: 16 })
        .borderRadius(6)
        .onClick(() => {
          this.showFilterDialog = true
        })
      }
      .width('100%')
      .margin({ bottom: 20 })

      if (this.selectedType !== 'all' || this.selectedCategory !== 'all' || this.selectedDateRange !== 'all') {
        Row() {
          ForEach(this.getActiveFilters(), (filter: string) => {
            Text(filter)
              .fontSize(11)
              .fontColor('#2196F3')
              .backgroundColor('#E3F2FD')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(4)
              .margin({ right: 8 })
          })
          
          Button() {
            Text('清除')
              .fontSize(11)
              .fontColor('#F44336')
          }
          .backgroundColor('#FFEBEE')
          .height(28)
          .padding({ left: 12, right: 12 })
          .borderRadius(4)
          .onClick(() => {
            this.clearFilters()
          })
        }
        .width('100%')
        .margin({ bottom: 16 })
      }

      List({ space: 8 }) {
        ForEach(this.filteredTransactions, (item: Transaction) => {
          ListItem() {
            this.TransactionItem(item)
          }
          .transition({ type: TransitionType.Insert, opacity: 0, scale: { x: 0.8, y: 0.8 } })
          .transition({ type: TransitionType.Delete, opacity: 0, scale: { x: 0.8, y: 0.8 } })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .opacity(this.listOpacity)
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .margin({ top: 12, left: 16, right: 16, bottom: 16 })
    .borderRadius(8)
    .layoutWeight(1)
  }

  getActiveFilters(): string[] {
    const filters: string[] = []
    
    if (this.selectedType === 'income') {
      filters.push('收入')
    } else if (this.selectedType === 'expense') {
      filters.push('支出')
    }
    
    if (this.selectedCategory !== 'all') {
      filters.push(this.selectedCategory)
    }
    
    if (this.selectedDateRange === 'today') {
      filters.push('今天')
    } else if (this.selectedDateRange === 'week') {
      filters.push('本周')
    } else if (this.selectedDateRange === 'month') {
      filters.push('本月')
    }
    
    return filters
  }

  clearFilters(): void {
    this.selectedType = 'all'
    this.selectedCategory = 'all'
    this.selectedDateRange = 'all'
    this.applyFilters()
  }

  @Builder
  TransactionItem(item: Transaction) {
    Row() {
      Column() {
        Row() {
          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
          Blank()
          Text((item.type === 'income' ? '+' : '-') + '¥' + item.amount.toFixed(2))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.type === 'income' ? '#4CAF50' : '#F44336')
        }
        .width('100%')

        Row() {
          Text(item.category)
            .fontSize(12)
            .fontColor('#757575')
          Text(' · ')
            .fontSize(12)
            .fontColor('#9E9E9E')
          Text(item.date)
            .fontSize(12)
            .fontColor('#757575')
          Blank()
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row() {
        Button() {
          Text('✏')
            .fontSize(16)
            .fontColor('#2196F3')
        }
        .width(36)
        .height(36)
        .backgroundColor('#F0F0F0')
        .borderRadius(6)
        .margin({ right: 8 })
        .onClick(() => {
          this.showEditDialog(item)
        })

        Button() {
          Text('🗑')
            .fontSize(16)
            .fontColor('#F44336')
        }
        .width(36)
        .height(36)
        .backgroundColor('#FFEBEE')
        .borderRadius(6)
        .onClick(async () => {
          await this.deleteTransaction(item.id)
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F5F5F5')
    .borderRadius(6)
    .border({ width: 1, color: '#EEEEEE' })
  }

  @Builder
  FilterDialog() {
    Column() {
      Column() {
        Row() {
          Text('筛选')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
          Blank()
          Button() {
            Text('×')
              .fontSize(24)
              .fontColor('#757575')
          }
          .width(36)
          .height(36)
          .backgroundColor('#F0F0F0')
          .borderRadius(6)
          .onClick(() => {
            this.showFilterDialog = false
          })
        }
        .width('100%')
        .margin({ bottom: 24 })

        Column() {
          Text('账单类型')
            .fontSize(13)
            .fontColor('#757575')
            .width('100%')
            .margin({ bottom: 16 })

          Flex({ wrap: FlexWrap.Wrap }) {
            Text('全部')
              .fontSize(14)
              .fontColor(this.selectedType === 'all' ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedType === 'all' ? '#2196F3' : '#F0F0F0')
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedType = 'all'
              })

            Text('收入')
              .fontSize(14)
              .fontColor(this.selectedType === 'income' ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedType === 'income' ? '#4CAF50' : '#F0F0F0')
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedType = 'income'
              })

            Text('支出')
              .fontSize(14)
              .fontColor(this.selectedType === 'expense' ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedType === 'expense' ? '#F44336' : '#F0F0F0')
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedType = 'expense'
              })
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 24 })

        Column() {
          Text('日期范围')
            .fontSize(13)
            .fontColor('#757575')
            .width('100%')
            .margin({ bottom: 16 })

          Flex({ wrap: FlexWrap.Wrap }) {
            Text('全部')
              .fontSize(14)
              .fontColor(this.selectedDateRange === 'all' ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedDateRange === 'all' ? '#2196F3' : '#F0F0F0')
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedDateRange = 'all'
              })

            Text('今天')
              .fontSize(14)
              .fontColor(this.selectedDateRange === 'today' ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedDateRange === 'today' ? '#2196F3' : '#F0F0F0')
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedDateRange = 'today'
              })

            Text('本周')
              .fontSize(14)
              .fontColor(this.selectedDateRange === 'week' ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedDateRange === 'week' ? '#2196F3' : '#F0F0F0')
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedDateRange = 'week'
              })

            Text('本月')
              .fontSize(14)
              .fontColor(this.selectedDateRange === 'month' ? '#FFFFFF' : '#1A1A1A')
              .backgroundColor(this.selectedDateRange === 'month' ? '#2196F3' : '#F0F0F0')
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .borderRadius(6)
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedDateRange = 'month'
              })
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 32 })

        Row() {
          Button('重置')
            .width('48%')
            .height(48)
            .fontSize(16)
            .fontColor('#757575')
            .backgroundColor('#F0F0F0')
            .borderRadius(6)
            .onClick(() => {
              this.clearFilters()
            })

          Button('应用')
            .width('48%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#2196F3')
            .borderRadius(6)
            .onClick(() => {
              this.applyFilters()
              this.showFilterDialog = false
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000080')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.showFilterDialog = false
    })
  }
}
