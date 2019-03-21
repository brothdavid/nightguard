//
//  StatsPeriodSelectorView.swift
//  nightguard
//
//  Created by Florian Preknya on 3/18/19.
//  Copyright © 2019 private. All rights reserved.
//

import UIKit

class StatsPeriodSelectorView: BasicStatsControl {
    
    var onPeriodChangeRequest: ((BasicStats.Period) -> Void)?
    
    fileprivate var periods: [BasicStats.Period] = [
        .last24h,
        .last8h,
        .today,
        .yesterday,
        .todayAndYesterday
    ]
    
    override func commonInit() {
        super.commonInit()
        
        diagramView.dataSource = self
        valueLabel?.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 11 : 13)
    }
    
    override func modelWasSet() {
        super.modelWasSet()
        
        updateTitleView(name: "Stats Period", value: model?.period.description)
    }
    
    override func changePage() {
        guard let period = self.model?.period else { return }
        let nextPeriodIndex = ((periods.firstIndex(of: period) ?? -1) + 1) % periods.count
        onPeriodChangeRequest?(periods[nextPeriodIndex])
    }
}

extension StatsPeriodSelectorView: SMDiagramViewDataSource {
    
    @objc func numberOfSegmentsIn(diagramView: SMDiagramView) -> Int {
        return 1
    }
    
    //    func diagramView(_ diagramView: SMDiagramView, colorForSegmentAtIndex index: NSInteger, angle: CGFloat) -> UIColor? {
    //
    //        return UIColor.white.withAlphaComponent(0.025)
    //    }
    
    func diagramView(_ diagramView: SMDiagramView, radiusForSegmentAtIndex index: NSInteger, proportion: CGFloat, angle: CGFloat) -> CGFloat {
        return (diagramView.frame.size.height - 2/*diagramView.arcWidth*/) / 2
    }
    
    func diagramView(_ diagramView: SMDiagramView, lineWidthForSegmentAtIndex index: NSInteger, angle: CGFloat) -> CGFloat {
        //not called for SMDiagramViewModeSegment
        return 2.0
    }
}
