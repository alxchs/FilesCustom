// Copyright (c) Files Community
// SPDX-License-Identifier: MPL-2.0

using Windows.Win32;

namespace Files.App.Helpers
{
	/// <summary>
	/// Returns memory to the OS after large amounts of items are dropped, once the app has been quiet for a moment.
	/// </summary>
	public static class AppMemoryHelper
	{
		private const int QuietWindowMs = 2000;
		private const int SweepDelayMs = 6000;
		private const int MaxSweepPasses = 4;
		private const long SweepContinueBytes = 64 * 1024 * 1024;

		private static long lastActivityTicks;
		private static int trimRequested;
		private static int workerRunning;

		/// <summary>
		/// Postpones a pending trim; call from hot interaction paths so collections never land mid-gesture.
		/// </summary>
		public static void NotifyActivity()
		{
			Interlocked.Exchange(ref lastActivityTicks, Environment.TickCount64);
		}

		/// <summary>
		/// Requests a full collection once the app has been quiet for a moment; concurrent requests coalesce.
		/// </summary>
		public static void RequestTrim()
		{
			NotifyActivity();
			Interlocked.Exchange(ref trimRequested, 1);
			EnsureWorker();
		}

		private static void EnsureWorker()
		{
			if (Interlocked.CompareExchange(ref workerRunning, 1, 0) != 0)
				return;

			_ = Task.Run(async () =>
			{
				while (Interlocked.Exchange(ref trimRequested, 0) == 1)
				{
					while (Environment.TickCount64 - Interlocked.Read(ref lastActivityTicks) < QuietWindowMs)
						await Task.Delay(500);

					Collect();
				}

				Interlocked.Exchange(ref workerRunning, 0);

				// A request that landed between the loop exit and the reset above must not be dropped
				if (Volatile.Read(ref trimRequested) == 1)
					EnsureWorker();
			});
		}

		private static void Collect()
		{
			// When closing to background, perform a compacting collection; otherwise non-blocking optimized collection
			if (App.AppModel?.IsMainWindowClosed ?? false)
			{
				GC.Collect(GC.MaxGeneration, GCCollectionMode.Aggressive, blocking: true, compacting: true);
				GC.WaitForPendingFinalizers();
				GC.Collect(GC.MaxGeneration, GCCollectionMode.Forced, blocking: true, compacting: true);
			}
			else
			{
				GC.Collect(GC.MaxGeneration, GCCollectionMode.Optimized, blocking: false);
			}
		}
	}
}
