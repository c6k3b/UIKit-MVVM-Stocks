//  StockChartView.swift
//  Created by aa on 12/2/22.

import UIKit
import Charts

final class StockChartView: UIView {
    // MARK: - UIComponents
    private let chartView: LineChartView = {
        $0.setScaleEnabled(true)
        $0.pinchZoomEnabled = false
        $0.xAxis.enabled = false
        $0.drawGridBackgroundEnabled = false
        $0.leftAxis.enabled = false
        $0.rightAxis.enabled = false
        $0.legend.enabled = false
        return $0
    }(LineChartView())

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }

    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()
        for (index, value) in viewModel.data.enumerated() {
            entries.append(.init(x: Double(index), y: value))
        }

        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend

        let dataSet = LineChartDataSet(entries: entries, label: "7 Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false

        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }

    func reset() {
        chartView.data = nil
    }
}

// MARK: - ViewModel
extension StockChartView {
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
    }
}
