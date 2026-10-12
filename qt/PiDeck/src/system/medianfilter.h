#pragma once

#include <QList>

#include <algorithm>

// A mean still shows outliers: the package thermal sensor jumps ~30 °C for a
// few hundred milliseconds on any turbo boost, and one such sample in five
// drags an average up by six degrees. A median drops it entirely.
class MedianFilter
{
public:
    explicit MedianFilter(int window) : m_window(window) {}

    void push(int sample)
    {
        m_samples.append(sample);
        if (m_samples.size() > m_window)
            m_samples.removeFirst();
    }

    int value() const
    {
        if (m_samples.isEmpty())
            return -1;

        QList<int> sorted = m_samples;
        std::sort(sorted.begin(), sorted.end());
        return sorted.at(sorted.size() / 2);
    }

    int size() const { return m_samples.size(); }

    void reset() { m_samples.clear(); }

private:
    int m_window;
    QList<int> m_samples;
};
