using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace PropertyExplorer
{
    public enum PROPDESC_ENUMFILTER
    {
        PDEF_ALL = 0,
        PDEF_SYSTEM = 1,
        PDEF_NONSYSTEM = 2,
        PDEF_VIEWABLE = 3,
        PDEF_QUERYABLE = 4,
        PDEF_INFULLTEXTQUERY = 5,
        PDEF_COLUMN = 6
    }

    [Flags]
    public enum PROPDESC_VIEW_FLAGS : uint
    {
        PDVF_DEFAULT = 0x00000000,
        PDVF_CENTERALIGN = 0x00000001,
        PDVF_RIGHTALIGN = 0x00000002,
        PDVF_BEGINGROUP = 0x00000004,
        PDVF_FILLAREA = 0x00000008,
        PDVF_SORTDESCENDING = 0x00000010,
        PDVF_SHOWONLYIFPRESENT = 0x00000020,
        PDVF_SHOWBYDEFAULT = 0x00000040,
        PDVF_SHOWINPRIMARYLIST = 0x00000080,
        PDVF_SHOWINSECONDARYLIST = 0x00000100,
        PDVF_HIDELABEL = 0x00000200,
        PDVF_HIDDEN = 0x00000800,
        PDVF_CANWRAP = 0x00001000,
        PDVF_MASK_ALL = 0x00001BFF
    }

    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    public struct PROPERTYKEY
    {
        public Guid fmtid;
        public uint pid;
        public override string ToString() => $"{{{fmtid}}}, {pid}";
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct PROPVARIANT
    {
        [FieldOffset(0)] public ushort vt;
        [FieldOffset(2)] public ushort wReserved1;
        [FieldOffset(4)] public ushort wReserved2;
        [FieldOffset(6)] public ushort wReserved3;
        [FieldOffset(8)] public IntPtr ptrVal;
        [FieldOffset(8)] public long int64Val;
        [FieldOffset(8)] public int int32Val;
    }

    [ComImport]
    [Guid("1f9fc1d0-c39b-4b26-817f-011967d3440e")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IPropertyDescriptionList
    {
        uint GetCount();
        [return: MarshalAs(UnmanagedType.Interface)]
        object GetAt(uint iElem, in Guid riid);
    }

    [ComImport]
    [Guid("6f79d558-3e96-4549-a1d1-7d75d2288814")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IPropertyDescription
    {
        void GetPropertyKey(out PROPERTYKEY pkey);
        void GetCanonicalName([MarshalAs(UnmanagedType.LPWStr)] out string ppszName);
        void GetPropertyType(out ushort pvartype);
        void GetDisplayName([MarshalAs(UnmanagedType.LPWStr)] out string ppszName);
        void GetEditInvitation([MarshalAs(UnmanagedType.LPWStr)] out string ppszInvite);
        void GetTypeFlags(uint mask, out uint ppdtFlags);
        void GetViewFlags(out PROPDESC_VIEW_FLAGS ppdvFlags);
        void GetDefaultColumnWidth(out uint pcxChars);
        void GetDisplayType(out uint pdisplaytype);
        void GetColumnState(out uint pcsFlags);
        void GetGroupingRange(out uint pgr);
        void GetRelativeDescriptionType(out uint prdt);
        void GetRelativeDescription(IntPtr propvar1, IntPtr propvar2, [MarshalAs(UnmanagedType.LPWStr)] out string ppszDesc1, [MarshalAs(UnmanagedType.LPWStr)] out string ppszDesc2);
        void GetSortDescription(out uint psd);
        void GetSortDescriptionLabel(bool fDescending, [MarshalAs(UnmanagedType.LPWStr)] out string ppszDescription);
        void GetAggregationType(out uint paggtype);
        void GetConditionType(out uint pcontype, out uint pop);
    }

    [ComImport]
    [Guid("7e9fb0d3-919f-4307-ab2e-9b1860310c93")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IShellItem2
    {
        // IShellItem methods
        void BindToHandler(IntPtr pbc, in Guid bhid, in Guid riid, out IntPtr ppv);
        void GetParent(out IntPtr ppsi);
        void GetDisplayName(uint sigdnName, [MarshalAs(UnmanagedType.LPWStr)] out string ppszName);
        void GetAttributes(uint sfgaoMask, out uint psfgaoAttribs);
        void Compare(IntPtr psi, uint hint, out int piOrder);

        // IShellItem2 methods
        void GetPropertyStore(int flags, in Guid riid, out IntPtr ppv);
        void GetPropertyStoreWithCreateObject(int flags, IntPtr punkCreateObject, in Guid riid, out IntPtr ppv);
        void GetPropertyStoreForKeys(IntPtr rgKeys, uint cKeys, int flags, in Guid riid, out IntPtr ppv);
        void GetPropertyDescriptionList(in PROPERTYKEY keyType, in Guid riid, out IntPtr ppv);
        void Update(IntPtr pbc);
        [PreserveSig]
        int GetProperty(in PROPERTYKEY key, out PROPVARIANT propvar);
        void GetCLSID(in PROPERTYKEY key, out Guid pclsid);
        void GetFileTime(in PROPERTYKEY key, out System.Runtime.InteropServices.ComTypes.FILETIME pft);
        void GetInt32(in PROPERTYKEY key, out int pi);
        void GetString(in PROPERTYKEY key, [MarshalAs(UnmanagedType.LPWStr)] out string ppsz);
        void GetUInt32(in PROPERTYKEY key, out uint pui);
        void GetUInt64(in PROPERTYKEY key, out ulong pull);
        void GetBool(in PROPERTYKEY key, out bool pf);
    }

    public static class NativeMethods
    {
        [DllImport("propsys.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int PSEnumeratePropertyDescriptions(
            PROPDESC_ENUMFILTER filterOn,
            in Guid riid,
            [MarshalAs(UnmanagedType.Interface)] out IPropertyDescriptionList ppv
        );

        [DllImport("shell32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int SHCreateItemFromParsingName(
            [MarshalAs(UnmanagedType.LPWStr)] string pszPath,
            IntPtr pbc,
            in Guid riid,
            [MarshalAs(UnmanagedType.Interface)] out IShellItem2 ppv
        );

        [DllImport("propsys.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int PSGetPropertyKeyFromName(
            [MarshalAs(UnmanagedType.LPWStr)] string pszCanonicalName,
            out PROPERTYKEY propkey
        );

        [DllImport("propsys.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int PSFormatForDisplayAlloc(
            in PROPERTYKEY key,
            in PROPVARIANT propvar,
            uint pdffFlags,
            out IntPtr ppszDisplay
        );

        [DllImport("ole32.dll")]
        public static extern int PropVariantClear(ref PROPVARIANT pvar);

        [DllImport("ole32.dll")]
        public static extern void CoTaskMemFree(IntPtr pv);
    }

    public class PropRecord
    {
        public string CanonicalName { get; set; } = "";
        public string DisplayName { get; set; } = "";
        public string PropertyKey { get; set; } = "";
        public ushort VarType { get; set; }
        public uint DefaultWidthChars { get; set; }
        public uint ViewFlags { get; set; }
        public string Group { get; set; } = "General";
    }

    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;
            Console.WriteLine("=== Windows Property System Enumeration & Benchmark ===");

            var all = Enumerate(PROPDESC_ENUMFILTER.PDEF_ALL);
            var column = Enumerate(PROPDESC_ENUMFILTER.PDEF_COLUMN);
            var viewable = Enumerate(PROPDESC_ENUMFILTER.PDEF_VIEWABLE);

            Console.WriteLine($"Total Properties (PDEF_ALL): {all.Count}");
            Console.WriteLine($"Column Properties (PDEF_COLUMN): {column.Count}");
            Console.WriteLine($"Viewable Properties (PDEF_VIEWABLE): {viewable.Count}");

            // Grouping analysis
            var groups = column.GroupBy(p => p.Group).OrderByDescending(g => g.Count()).ToList();
            Console.WriteLine("\nTop Groups in Column Properties:");
            foreach (var g in groups.Take(20))
            {
                Console.WriteLine($"  {g.Key,-20} : {g.Count()} properties");
            }

            // Export to CSV
            string csvPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "windows_properties.csv");
            using (var sw = new StreamWriter(csvPath, false, Encoding.UTF8))
            {
                sw.WriteLine("CanonicalName,DisplayName,PropertyKey,VarType,DefaultWidthChars,ViewFlags,Group");
                foreach (var p in all)
                {
                    sw.WriteLine($"\"{p.CanonicalName}\",\"{p.DisplayName.Replace("\"", "\"\"")}\",\"{p.PropertyKey}\",{p.VarType},{p.DefaultWidthChars},{p.ViewFlags},\"{p.Group}\"");
                }
            }
            Console.WriteLine($"\nExported {all.Count} properties to CSV: {csvPath}");

            // Benchmark reading real file properties
            Console.WriteLine("\n=== T2: Benchmark de Leitura de Propriedades Reais ===");
            BenchmarkFileProperties();
        }

        static void BenchmarkFileProperties()
        {
            var testFiles = new List<string>
            {
                @"C:\FilesUXLab\sample.jpg",
                @"C:\Windows\Media\Alarm01.wav",
                @"C:\FilesUXLab\arquivo.txt"
            };

            var propertiesToTest = new Dictionary<string, string[]>
            {
                ["Image"] = new[] { "System.ItemNameDisplay", "System.Image.Dimensions", "System.Image.HorizontalSize", "System.Image.VerticalSize", "System.Size", "System.DateModified", "System.ItemTypeText" },
                ["Audio"] = new[] { "System.ItemNameDisplay", "System.Media.Duration", "System.Audio.EncodingBitrate", "System.Audio.SampleRate", "System.Audio.ChannelCount", "System.Size", "System.DateModified" },
                ["Text"]  = new[] { "System.ItemNameDisplay", "System.Size", "System.DateModified", "System.DateCreated", "System.ItemTypeText", "System.FileAttributesDisplayName" }
            };

            Guid shellItem2Guid = new Guid("7e9fb0d3-919f-4307-ab2e-9b1860310c93");

            foreach (var file in testFiles)
            {
                if (!File.Exists(file)) continue;

                string ext = Path.GetExtension(file).ToLowerInvariant();
                string category = ext == ".jpg" ? "Image" : ext == ".wav" ? "Audio" : "Text";
                var props = propertiesToTest[category];

                Console.WriteLine($"\n--- Arquivo de Teste: {Path.GetFileName(file)} ({category}) ---");

                int hr = NativeMethods.SHCreateItemFromParsingName(file, IntPtr.Zero, in shellItem2Guid, out IShellItem2 item);
                if (hr != 0 || item == null)
                {
                    Console.WriteLine($"  Erro ao abrir IShellItem2: 0x{hr:X8}");
                    continue;
                }

                // Warm up and display values
                foreach (var prop in props)
                {
                    string? val = ReadPropertyFormatted(item, prop);
                    Console.WriteLine($"  {prop,-35} = \"{val ?? "(vazio)"}\"");
                }

                // Latency measurement: 100 iterations
                int iterations = 100;
                var sw = Stopwatch.StartNew();
                for (int i = 0; i < iterations; i++)
                {
                    foreach (var prop in props)
                    {
                        ReadPropertyFormatted(item, prop);
                    }
                }
                sw.Stop();

                double totalMs = sw.Elapsed.TotalMilliseconds;
                double perItemMs = totalMs / iterations;
                double perPropMicroseconds = (totalMs * 1000.0) / (iterations * props.Length);

                Console.WriteLine($"\n  [Medição] {iterations} iterações de {props.Length} propriedades:");
                Console.WriteLine($"  Tempo médio por item ({props.Length} props): {perItemMs:F3} ms");
                Console.WriteLine($"  Tempo médio por propriedade: {perPropMicroseconds:F1} µs (microssegundos)");
                Console.WriteLine($"  Projeção para 10.000 itens (síncrono puro): {perItemMs * 10:F1} segundos");
                Console.WriteLine($"  Conclusão: Leitura de 10 mil itens SÍNCRONA trava a UI (~{perItemMs * 10:F0}s).");
                Console.WriteLine($"  Requisito mandatória: Carregamento ASSÍNCRONO e VIRTUALIZADO (apenas itens em tela).");
            }
        }

        static string? ReadPropertyFormatted(IShellItem2 item, string canonicalName)
        {
            int hrKey = NativeMethods.PSGetPropertyKeyFromName(canonicalName, out PROPERTYKEY key);
            if (hrKey != 0)
                return $"[KeyErr:0x{hrKey:X8}]";

            int hrProp = item.GetProperty(in key, out PROPVARIANT val);
            if (hrProp != 0)
                return $"[PropErr:0x{hrProp:X8}]";

            try
            {
                int hrDisp = NativeMethods.PSFormatForDisplayAlloc(in key, in val, 0, out IntPtr pDisplay);
                if (hrDisp == 0 && pDisplay != IntPtr.Zero)
                {
                    try
                    {
                        return Marshal.PtrToStringUni(pDisplay);
                    }
                    finally
                    {
                        NativeMethods.CoTaskMemFree(pDisplay);
                    }
                }
                return $"[DispErr:0x{hrDisp:X8}, vt={val.vt}]";
            }
            finally
            {
                NativeMethods.PropVariantClear(ref val);
            }
            return null;
        }

        static List<PropRecord> Enumerate(PROPDESC_ENUMFILTER filter)
        {
            var list = new List<PropRecord>();
            Guid listGuid = new Guid("1f9fc1d0-c39b-4b26-817f-011967d3440e");
            Guid descGuid = new Guid("6f79d558-3e96-4549-a1d1-7d75d2288814");

            int hr = NativeMethods.PSEnumeratePropertyDescriptions(filter, in listGuid, out IPropertyDescriptionList propList);
            if (hr != 0 || propList == null)
            {
                Console.WriteLine($"PSEnumeratePropertyDescriptions({filter}) returned 0x{hr:X8}");
                return list;
            }

            uint count = propList.GetCount();
            for (uint i = 0; i < count; i++)
            {
                try
                {
                    var desc = (IPropertyDescription)propList.GetAt(i, in descGuid);
                    if (desc == null) continue;

                    desc.GetCanonicalName(out string canon);
                    desc.GetDisplayName(out string display);
                    desc.GetPropertyKey(out PROPERTYKEY key);
                    desc.GetPropertyType(out ushort vt);
                    desc.GetDefaultColumnWidth(out uint chars);
                    desc.GetViewFlags(out PROPDESC_VIEW_FLAGS flags);

                    string grp = "General";
                    if (!string.IsNullOrEmpty(canon))
                    {
                        var parts = canon.Split('.');
                        if (parts.Length > 1) grp = parts[1];
                    }

                    list.Add(new PropRecord
                    {
                        CanonicalName = canon ?? "",
                        DisplayName = display ?? canon ?? "",
                        PropertyKey = key.ToString(),
                        VarType = vt,
                        DefaultWidthChars = chars,
                        ViewFlags = (uint)flags,
                        Group = grp
                    });
                }
                catch
                {
                }
            }
            return list;
        }
    }
}
