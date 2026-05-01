part of '../bubble_picker_widget.dart';

class _KalmanFilter {
  double q; 
  double r; 
  double p;
  double x; 
  double k; 

  
  _KalmanFilter({
    required this.q,
    required this.r,
    required this.p,
    required this.x,
  }) : k = 0.0; 

  double update(double measurement) {
    p = p + q;

    // 업데이트 단계
    k = p / (p + r);
    x = x + k * (measurement - x);
    p = (1 - k) * p;

    return x;
  }
}
