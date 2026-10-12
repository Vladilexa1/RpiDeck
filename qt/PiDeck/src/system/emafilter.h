#pragma once

#include <cmath>

// Second smoothing stage, and the one that actually tames this signal: under a
// load that switches on and off every couple of seconds the package sensor
// genuinely alternates between ~50 °C and ~93 °C, so a median has two modes to
// pick from and flips with the duty cycle. An exponential average settles
// between them and drifts instead of jumping.
class EmaFilter
{
public:
    // alpha is per sample: time constant ≈ sampleInterval / alpha
    explicit EmaFilter(double alpha) : m_alpha(alpha) {}

    void push(int sample)
    {
        m_value = m_ready ? m_value + m_alpha * (double(sample) - m_value) : double(sample);
        m_ready = true;
    }

    bool isReady() const { return m_ready; }
    int value() const { return int(std::lround(m_value)); }

    void reset()
    {
        m_ready = false;
        m_value = 0.0;
    }

private:
    double m_alpha;
    double m_value = 0.0;
    bool m_ready = false;
};
